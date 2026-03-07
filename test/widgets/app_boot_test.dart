import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('shows home selector with elderly and child entries',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('Who is this for?'), findsOneWidget);
    expect(find.text('Elderly'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });
}
