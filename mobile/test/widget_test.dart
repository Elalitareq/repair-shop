// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:repair_shop_mobile/core/app/app.dart';

void main() {
  testWidgets('App loads login page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: RepairShopApp()));

    // Verify that the login page loads
    expect(find.text('Repair Shop Manager'), findsOneWidget);
    expect(find.text('Username or Email'), findsOneWidget);
  });
}
