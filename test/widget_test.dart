import 'package:blog/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const BLogApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(BLogApp), findsOneWidget);
  });
}
