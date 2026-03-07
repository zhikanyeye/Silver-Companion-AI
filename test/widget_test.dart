import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('App boots into home selector screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('为谁服务？'), findsOneWidget);
    expect(find.byType(HomeSelectorScreen), findsOneWidget);
  });
}
