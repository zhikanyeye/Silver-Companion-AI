import 'package:flutter_test/flutter_test.dart';

import 'package:yinling_zhiban_demo/app.dart';

void main() {
  testWidgets('App shows home selector options',
      (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    expect(find.text('为谁服务？'), findsOneWidget);
    expect(find.text('长者'), findsOneWidget);
    expect(find.text('儿童'), findsOneWidget);
    expect(find.byType(HomeSelectorScreen), findsOneWidget);
  });
}
