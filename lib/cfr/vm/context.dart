import 'dart:convert';

import 'package:hydro_sdk/cfr/moduleDebugInfo.dart';
import 'package:hydro_sdk/cfr/moduleDebugInfoRaw.dart';
import 'package:hydro_sdk/cfr/thread/thread.dart';
import 'package:hydro_sdk/cfr/util.dart';
import 'package:hydro_sdk/cfr/vm/closure.dart';
import 'package:hydro_sdk/cfr/vm/frame.dart';
import 'package:hydro_sdk/cfr/vm/table.dart';
import 'package:meta/meta.dart';

class SymbolWithDistance {
  final int distance;
  final ModuleDebugInfo moduleDebugInfo;

  SymbolWithDistance({@required this.distance, @required this.moduleDebugInfo});
}

class LuaError {
  LuaError(
      {@required this.errMsg,
      @required Frame frame,
      @required this.inst,
      @required this.dartStackTrace})
      : _frames = [frame];
  final String errMsg;
  List<Frame> _frames;
  final int inst;
  final StackTrace dartStackTrace;
  List<ModuleDebugInfo> _extractedSymbols = [];
  List<ModuleDebugInfo> get extractedSymbols => _extractedSymbols;

  void addFrame({@required Frame frame}) => _frames = [..._frames, frame];

  void _symbolicateFrame(
      {@required ModuleDebugInfoRaw moduleDebugInfoRaw,
      @required Frame frame}) {
    List<ModuleDebugInfo> symbols = json
        .decode(moduleDebugInfoRaw.raw)
        ?.map((x) => ModuleDebugInfo.fromJson(x))
        ?.toList()
        ?.cast<ModuleDebugInfo>();

    int moduleLineNumber = maybeAt(frame.prototype.lines, inst);

    List<SymbolWithDistance> symbolsWithDistance = symbols
        .map((e) => SymbolWithDistance(
            distance: moduleLineNumber - e.lineStart, moduleDebugInfo: e))
        ?.toList();
    symbolsWithDistance.removeWhere((element) => element.distance < 0);
    symbolsWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

    ModuleDebugInfo closestSymbol = symbolsWithDistance[0].moduleDebugInfo;

    _extractedSymbols.add(closestSymbol);
  }

  void addSymbolicatedStackTrace(
      {@required ModuleDebugInfoRaw moduleDebugInfoRaw}) {
    _frames.forEach((x) {
      _symbolicateFrame(frame: x, moduleDebugInfoRaw: moduleDebugInfoRaw);
    });
  }

  String toString() {
    var res = "";
    if (_extractedSymbols?.isNotEmpty ?? false) {
      res += "$errMsg\n";
      res += "Error raised in: \n";

      _extractedSymbols.forEach((element) {
        if (element != null) {
          res += "  ${element.symbolName}\n";

          if (element.originalFileName != "lualib_bundle") {
            res +=
                "     defined in ${element.originalFileName}:${element.originalLineStart}\n";
          } else {
            res += "    <generated function>\n";
          }
        }
      });
    }

    res += "VM stacktrace follows:\n";
    res += dartStackTrace.toString();

    return res;
  }
}

typedef List<dynamic> LuaDartFunc(List<dynamic> params);
typedef List<dynamic> LuaDartDebugFunc(Thread thread, List<dynamic> params);
typedef num ArithCB(num x, num y);
typedef num UArithCB(num x);

LuaDartFunc makeLuaDartFunc({@required LuaDartFunc func}) {
  return func;
}

class TypeMatcher<T> {
  const TypeMatcher();
  bool matches(dynamic x) => x is T;
  toString() {
    if (T == String) return "string";
    if (T == HydroTable) return "table";
    if (T == num) return "number";
    if (T == Closure) return "function";
    if (T == LuaDartFunc) return "function";
    if (T == Thread) return "thread";
    if (T == Null) return "nil";
    return T.toString();
  }
}

class Context {
  Context({
    this.userdata,
    @required this.env,
  });

  dynamic userdata;

  HydroTable env;
  HydroTable stringMetatable;
  LuaDartFunc yield;

  static String getTypename(dynamic v) {
    if (v is String) return "string";
    if (v is HydroTable) return "table";
    if (v is num) return "number";
    if (v is Closure) return "function";
    if (v is LuaDartFunc) return "function";
    if (v is Thread) return "thread";
    if (v == null) return "nil";
    return "${v.runtimeType}";
  }

  static dynamic getAny(List<dynamic> args, int idx, String name) {
    if (args.length <= idx)
      throw "bad argument #${idx + 1} to '$name' (value expected, got no value)";
    return args[idx];
  }

  static T getArg1<T>(List<dynamic> args, int idx, String name) {
    if (args.length <= idx)
      throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got no value)";
    var x = args[idx];
    if (new TypeMatcher<T>().matches(x)) return x;
    throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got ${getTypename(x)})";
  }

  static dynamic getArg2<T, T2>(List<dynamic> args, int idx, String name) {
    if (args.length <= idx)
      throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got no value)";
    var x = args[idx];
    if (new TypeMatcher<T>().matches(x) || new TypeMatcher<T2>().matches(x))
      return x;
    throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got ${getTypename(x)})";
  }

  static dynamic getArg3<T, T2, T3>(List<dynamic> args, int idx, String name) {
    if (args.length <= idx)
      throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got no value)";
    var x = args[idx];
    if (new TypeMatcher<T>().matches(x) ||
        new TypeMatcher<T2>().matches(x) ||
        new TypeMatcher<T3>().matches(x)) return x;
    throw "bad argument #${idx + 1} to '$name' (${new TypeMatcher<T>()} expected, got ${getTypename(x)})";
  }

  static dynamic getMetatable(dynamic x) {
    if (x is HydroTable && x.metatable != null) {
      return x.metatable.map.containsKey("__metatable")
          ? x.metatable.map["__metatable"]
          : x.metatable;
    }
    return null;
  }

  static dynamic getLength(dynamic x) {
    if (hasMetamethod(x, "__len")) {
      return maybeAt(invokeMetamethod(x, "__len", [x]), 0);
    } else if (x is HydroTable) {
      return x.length;
    } else if (x is String) {
      return x.length;
    } else {
      throw "attempt to get length of a ${getTypename(x)} value";
    }
  }

  dynamic tableIndex(dynamic x, dynamic y) {
    if (x is HydroTable) {
      var o = x.rawget(y);
      if (o != null) return o;
      if (x.metatable == null) return null;
      var ni = x.metatable.map["__index"];
      if (ni == null) return null;
      if (ni is Closure) return ni([this, y]);
      return tableIndex(ni, y);
    } else if (x is String) {
      return stringMetatable.rawget(y);
    } else if (x is Map<dynamic, dynamic>) {
      return x[y];
    } else {
      throw "attempt to index a ${getTypename(x)} value $x $y";
    }
  }

  static void tableSet(dynamic x, dynamic k, dynamic v) {
    if (x is HydroTable) {
      if (x.map.containsKey(k) &&
          x.metatable != null &&
          x.metatable.map.containsKey("__newindex")) {
        var ni = x.metatable.map["__newindex"];
        if (ni is Closure) {
          ni([x, k, v]);
        } else {
          tableSet(ni, k, v);
        }
      } else {
        x.rawset(k, v);
      }
    } else if (x is Map<dynamic, dynamic>) {
      x[k] = v;
    } else {
      throw "attempt to index a ${getTypename(x)} value";
    }
  }

  static String numToString(num x) {
    if (x is int) return x.toString();
    if (x == double.infinity) return "inf";
    if (x != x) return "-nan";
    if (x == double.negativeInfinity) return "-inf";
    return x.toString().replaceFirst(new RegExp(r"\.0$"), "");
  }

  static String luaToString(dynamic x) {
    if (x == null) {
      return "nil";
    } else if (x is num) {
      return numToString(x);
    } else if (hasMetamethod(x, "__tostring")) {
      return maybeAt(invokeMetamethod(x, "__tostring", [x]), 0);
    } else if (x is String) {
      return x;
    } else if (x is bool) {
      return x.toString();
    } else {
      return x.toString();
      //return "${getTypename(x)}: ${(x.hashCode % 0x100000000).toRadixString(16).padLeft(8, "0")}";
    }
  }

  static const keywords = const [
    "and",
    "break",
    "do",
    "else",
    "elseif",
    "or",
    "end",
    "false",
    "for",
    "function",
    "goto",
    "if",
    "in",
    "local",
    "nil",
    "not",
    "while",
    "repeat",
    "return",
    "then",
    "true",
    "until",
  ];

  static String luaSerialize(dynamic x) {
    if (x is String)
      return "\"${luaEscape(x)}\"";
    else if (x is HydroTable) {
      var o = "{";
      for (var e in x.arr) {
        o += luaSerialize(e) + ",";
      }

      for (var k in x.map.keys) {
        if (k is String &&
            new RegExp("^[a-zA-Z_][a-zA-Z0-9_]*\$").hasMatch(k) &&
            !keywords.contains(k)) {
          o += "$k = ";
        } else {
          o += "[${luaSerialize(k)}] = ";
        }
        o += "${luaSerialize(x)},";
      }

      if (o.endsWith(",")) o = o.substring(0, o.length - 1);
      return "$o}";
    } else
      return luaToString(x);
  }

  static dynamic luaConcat(dynamic x, dynamic y) {
    if (hasMetamethod(x, "__concat")) {
      return maybeAt(invokeMetamethod(x, "__concat", [x, y]), 0);
    } else if (hasMetamethod(y, "__concat")) {
      return maybeAt(invokeMetamethod(y, "__concat", [x, y]), 0);
    } else if (x is! num && x is! String) {
      throw "attempt to concatenate a ${getTypename(x)} value";
    } else if (y is! num && x is! String) {
      throw "attempt to concatenate a ${getTypename(y)} value";
    } else {
      return luaToString(x) + luaToString(y);
    }
  }

  static List<dynamic> invokeMetamethod(
      dynamic x, String name, List<dynamic> params) {
    if (x is HydroTable) {
      if (x.map[name] is! Closure) throw "attempt to call table value";
      return x.map[name](params);
    } else {
      throw "attempt to invoke metamethod on a ${getTypename(x)} value";
    }
  }

  static bool hasMetamethod(dynamic x, String method) =>
      x is HydroTable &&
      x.metatable != null &&
      x.metatable.map.containsKey(method);

  static dynamic attemptArithmetic(
      dynamic x, dynamic y, String method, ArithCB op) {
    if (hasMetamethod(x, method)) {
      return maybeAt(invokeMetamethod(x, method, [x, y]), 0);
    } else if (hasMetamethod(y, method)) {
      return maybeAt(invokeMetamethod(y, method, [x, y]), 0);
    } else if (x is! num) {
      throw "attempt to perform arithmetic on a ${getTypename(x)} value";
    } else if (y is! num) {
      throw "attempt to perform arithmetic on a ${getTypename(y)} value";
    } else {
      return op(x, y);
    }
  }

  static num attemptUnary(dynamic x, String method, UArithCB op) {
    if (hasMetamethod(x, method)) {
      return maybeAt(invokeMetamethod(x, method, [x]), 0);
    } else if (x is! num) {
      throw "attempt to perform arithmetic on a ${getTypename(x)} value";
    } else {
      return op(x);
    }
  }

  static bool checkEQ(dynamic x, dynamic y) {
    if (hasMetamethod(x, "__eq") &&
        hasMetamethod(y, "__eq") &&
        (x as HydroTable).map["__eq"] == (y as HydroTable).map["__eq"]) {
      return truthy(invokeMetamethod(x, "__eq", [x, y]));
    } else {
      return x == y;
    }
  }

  static bool checkLT(dynamic x, dynamic y) {
    if (hasMetamethod(x, "__lt")) {
      return maybeAt(invokeMetamethod(x, "__lt", [x, y]), 0);
    } else if (hasMetamethod(y, "__lt")) {
      return maybeAt(invokeMetamethod(y, "__lt", [x, y]), 0);
    } else if (x is! num) {
      throw "attempt to compare ${getTypename(x)} with ${getTypename(y)}";
    } else if (y is! num) {
      throw "attempt to compare ${getTypename(y)} with ${getTypename(x)}";
    } else {
      return x < y;
    }
  }

  static bool checkLE(dynamic x, dynamic y) {
    if (hasMetamethod(x, "__le")) {
      return maybeAt(invokeMetamethod(x, "__le", [x, y]), 0);
    } else if (hasMetamethod(y, "__le")) {
      return maybeAt(invokeMetamethod(y, "__le", [x, y]), 0);
    } else if (x is! num) {
      throw "attempt to compare ${getTypename(x)} with ${getTypename(y)}";
    } else if (y is! num) {
      throw "attempt to compare ${getTypename(y)} with ${getTypename(x)}";
    } else {
      return !checkLT(y, x);
    }
  }

  static bool truthy(dynamic x) => x != null && x != false;
  static num add(num x, num y) => x + y;
  static num sub(num x, num y) => x - y;
  static num mul(num x, num y) => x * y;
  static num div(num x, num y) => x / y;
  static num mod(num x, num y) => x % y;
  static num unm(num x) => -x;
  static bool not(dynamic x) => !truthy(x);
}
