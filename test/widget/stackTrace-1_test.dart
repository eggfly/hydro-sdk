import 'dart:io';

import 'package:hydro_sdk/cfr/buildProfile.dart';
import 'package:hydro_sdk/cfr/moduleDebugInfoRaw.dart';
import 'package:hydro_sdk/cfr/vm/context.dart';
import 'package:hydro_sdk/hc.g.dart';
import 'package:hydro_sdk/hydroState.dart';
import 'package:hydro_sdk/runFromNetwork.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    await tester.runAsync(() async {
      String hashPath = "../assets/test/widget/stackTrace-1.ts.hc.sha256";
      String bytecodePath = "../assets/test/widget/stackTrace-1.ts.hc";
      String symbolsPath = "../assets/test/widget/stackTrace-1.ts.hc.symbols";

      HydroState state = HydroState();
      var closure = await state.loadBuffer(
          buffer: File(bytecodePath).readAsBytesSync(),
          name: bytecodePath,
          linkStatus: null,
          thunks: null);

      //This test doesn't make any sense if the fixtures were built in release mode.
      if (closure.closure.buildProfile == BuildProfile.mixed ||
          closure.closure.buildProfile == BuildProfile.release) {
        return;
      }

      WidgetsFlutterBinding.ensureInitialized();
      await tester.pumpWidget(RunFromNetwork(
        args: [],
        thunks: thunks,
        baseUrl: "http://127.0.0.1:3000/test/widget/stackTrace-1.hc",
        downloadHash: (String uri) async {
          var file = File(hashPath);
          var res = file.readAsStringSync();
          return res;
        },
        downloadByteCodeImage: (String uri) async {
          var file = File(bytecodePath);
          var res = file.readAsBytesSync();
          return res;
        },
        downloadDebugInfo: (String uri) async {
          var file = File(symbolsPath);
          var res = file.readAsStringSync();
          return ModuleDebugInfoRaw(res);
        },
      ));

      await Future.delayed(Duration(seconds: 5));

      await tester.pump();

      LuaError exception = tester.takeException();

      expect(exception, isNotNull);
      expect(
          exception.extractedSymbols[0].symbolName, "MyWidget.prototype.build");
      expect(exception.extractedSymbols[0].originalFileName,
          "test/widget/stackTrace-1.ts");
      expect(exception.extractedSymbols[0].originalLineStart, 34);
    });
  });
}
