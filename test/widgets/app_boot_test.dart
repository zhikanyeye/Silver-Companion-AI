import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('shows branded landing page with primary role entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    final semantics = tester.ensureSemantics();

    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.text('AI虚拟家人 + 社区互助的智慧养老平台'), findsOneWidget);
    expect(find.text('老人端'), findsOneWidget);
    expect(find.text('子女端'), findsOneWidget);
    expect(find.text('平台端'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));
    expect(find.bySemanticsLabel('进入老人端'), findsOneWidget);
    expect(find.bySemanticsLabel('进入子女端'), findsOneWidget);
    expect(find.bySemanticsLabel('进入平台端'), findsOneWidget);
    expect(find.bySemanticsLabel('打开设置'), findsOneWidget);

    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, hasLength(3));
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('老人关怀'), findsNothing);

    final buttons = tester.widgetList<Semantics>(find.byType(Semantics)).toList();
    expect(buttons, isNotEmpty);
    for (final semanticsWidget in buttons) {
      if (semanticsWidget.properties.label case final String label
          when label.startsWith('进入')) {
        expect(semanticsWidget.properties.button, isTrue);
      }
    }

    semantics.dispose();
  });
}
