// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flappy_bird/main.dart';

void main() {
  testWidgets('Main menu loads smoke test', (WidgetTester tester) async {
    // Mock the SharedPreferences local storage values for testing
    SharedPreferences.setMockInitialValues({});

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SkyBirdApp());

    // Wait for the game to complete loading and build overlays
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify that our main menu overlay loads and displays the title.
    expect(find.text('SKY BIRD'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);
  });
}
