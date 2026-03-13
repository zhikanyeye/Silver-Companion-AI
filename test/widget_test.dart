import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('App shows home selector options',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.text('老人端'), findsOneWidget);
    expect(find.text('子女端'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('平台端'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();

    expect(find.text('平台端'), findsOneWidget);
    expect(find.byType(HomeSelectorScreen), findsOneWidget);
  });
}
