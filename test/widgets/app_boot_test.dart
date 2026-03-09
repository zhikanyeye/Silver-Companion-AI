import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('shows localized home selector entries with tap affordances',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    final semantics = tester.ensureSemantics();

    expect(find.text('为谁服务？'), findsOneWidget);
    expect(find.text('长者'), findsOneWidget);
    expect(find.text('儿童'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(3));
    expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    expect(find.bySemanticsLabel('选择长者'), findsOneWidget);
    expect(find.bySemanticsLabel('选择儿童'), findsOneWidget);
    expect(find.bySemanticsLabel('打开设置'), findsOneWidget);

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(tiles, hasLength(3));
    for (final tile in tiles) {
      expect(tile.onTap, isNotNull);
    }

    semantics.dispose();
  });
}
