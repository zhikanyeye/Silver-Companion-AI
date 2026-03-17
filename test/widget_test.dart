import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('App boots to landing route', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('银龄智伴'), findsOneWidget);
    expect(find.text('让长辈在熟悉的关怀里，获得更安心的数字陪伴。'), findsOneWidget);
    expect(find.text('登录'), findsOneWidget);
    expect(find.text('注册'), findsOneWidget);
    expect(find.text('老人端'), findsNothing);
    expect(find.text('子女端'), findsNothing);
  });
}
