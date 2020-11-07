import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydro_sdk/integrationTestHarness.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
    await tester.pumpWidget(
        integrationTestHarness("../assets/test/widget/cupertinoButton-1.ts"));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(find.byKey(Key("cupertinoButton")), findsOneWidget);
    await tester.tap(find.byKey(Key("cupertinoButton")));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
},tags: "widget");
}
