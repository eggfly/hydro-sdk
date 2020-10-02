import 'package:hydro_sdk/swid/ir/swidEnum.dart';
import 'package:hydro_sdk/swid/transforms/ts/transformEnumToTs.dart';
import 'package:hydro_sdk/swid/transforms/transformPackageUri.dart';
import 'package:meta/meta.dart';

class TsOutSource {
  final String path;
  final String content;

  TsOutSource._({@required this.path, @required this.content});

  factory TsOutSource.fromEnum({@required SwidEnum swidEnum}) {
    return TsOutSource._(
        path: transformPackageUri(
          packageUri: swidEnum.originalPackagePath,
        ),
        content: transformEnumToTs(swidEnum: swidEnum));
  }
}
