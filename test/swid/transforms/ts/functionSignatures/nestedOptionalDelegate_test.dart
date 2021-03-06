import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidDeclarationModifiers.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidFunctionType.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidInterface.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidNullabilitySuffix.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidReferenceDeclarationKind.dart';
import 'package:hydro_sdk/swid/ir/frontend/dart/swidType.dart';
import 'package:hydro_sdk/swid/transforms/ts/trailingReturnTypeKind.dart';
import 'package:hydro_sdk/swid/transforms/ts/transformFunctionTypeToTs.dart';

void main() {
  LiveTestWidgetsFlutterBinding();
  testWidgets('', (WidgetTester tester) async {
    expect(
        //num? foo(int itemCount, [Widget Function([Duration Function(int? millis)? resolveDuration])? onTap])
        transformFunctionTypeToTs(
            trailingReturnTypeKind: TrailingReturnTypeKind.fatArrow,
            swidFunctionType: SwidFunctionType(
                namedDefaults: {},
                swidDeclarationModifiers: SwidDeclarationModifiers.empty(),
                name: "foo",
                originalPackagePath: "",
                normalParameterNames: ["itemCount"],
                normalParameterTypes: [
                  SwidType.fromSwidInterface(
                      swidInterface: SwidInterface(
                    typeArguments: [],
                    name: "int",
                    referenceDeclarationKind:
                        SwidReferenceDeclarationKind.classElement,
                    originalPackagePath: "",
                    nullabilitySuffix: SwidNullabilitySuffix.none,
                  )),
                ],
                optionalParameterNames: ["onTap"],
                optionalParameterTypes: [
                  SwidType.fromSwidFunctionType(
                      swidFunctionType: SwidFunctionType(
                          namedDefaults: {},
                          swidDeclarationModifiers:
                              SwidDeclarationModifiers.empty(),
                          name: "",
                          normalParameterNames: [],
                          normalParameterTypes: [],
                          namedParameterTypes: {},
                          optionalParameterNames: ["resolveDuration"],
                          optionalParameterTypes: [
                            SwidType.fromSwidFunctionType(
                                swidFunctionType: SwidFunctionType(
                                    namedDefaults: {},
                                    swidDeclarationModifiers:
                                        SwidDeclarationModifiers.empty(),
                                    name: "",
                                    normalParameterNames: ["millis"],
                                    namedParameterTypes: {},
                                    optionalParameterNames: [],
                                    optionalParameterTypes: [],
                                    normalParameterTypes: [
                                      SwidType.fromSwidInterface(
                                          swidInterface: SwidInterface(
                                        typeArguments: [],
                                        name: "int",
                                        referenceDeclarationKind:
                                            SwidReferenceDeclarationKind
                                                .classElement,
                                        nullabilitySuffix:
                                            SwidNullabilitySuffix.question,
                                        originalPackagePath: "",
                                      ))
                                    ],
                                    nullabilitySuffix:
                                        SwidNullabilitySuffix.question,
                                    originalPackagePath: "",
                                    returnType: SwidType.fromSwidInterface(
                                        swidInterface: SwidInterface(
                                      typeArguments: [],
                                      name: "Duration",
                                      referenceDeclarationKind:
                                          SwidReferenceDeclarationKind
                                              .classElement,
                                      originalPackagePath: "",
                                      nullabilitySuffix:
                                          SwidNullabilitySuffix.none,
                                    ))))
                          ],
                          originalPackagePath: "",
                          nullabilitySuffix: SwidNullabilitySuffix.question,
                          returnType: SwidType.fromSwidInterface(
                              swidInterface: SwidInterface(
                            typeArguments: [],
                            name: "Widget",
                            referenceDeclarationKind:
                                SwidReferenceDeclarationKind.classElement,
                            originalPackagePath: "",
                            nullabilitySuffix: SwidNullabilitySuffix.none,
                          ))))
                ],
                namedParameterTypes: {},
                nullabilitySuffix: SwidNullabilitySuffix.star,
                returnType: SwidType.fromSwidInterface(
                    swidInterface: SwidInterface(
                  typeArguments: [],
                  name: "num",
                  referenceDeclarationKind:
                      SwidReferenceDeclarationKind.classElement,
                  originalPackagePath: "dart:core",
                  nullabilitySuffix: SwidNullabilitySuffix.question,
                )))),
        "(itemCount : int, onTap? : (resolveDuration? : (millis? : int | undefined) => Duration) => Widget) => num | undefined");
  }, tags: "swid");
}
