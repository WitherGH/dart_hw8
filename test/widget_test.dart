import 'package:flutter_test/flutter_test.dart';

import 'package:dart_hw8/main.dart';

void main() {
  testWidgets('App starts and shows loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const TinderApiApp());
    expect(find.text('Loading fresh profiles...'), findsOneWidget);
  });
}
