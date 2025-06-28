import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class TestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortDelay = Duration(milliseconds: 500);
  static const Duration mediumDelay = Duration(seconds: 2);

  // Common screen sizes for testing
  static const Size mobileSize = Size(375, 667);
  static const Size tabletSize = Size(768, 1024);
  static const Size desktopSize = Size(1920, 1080);
  static const Size webSize = Size(1200, 800);

  // Helper method to wait for animations to complete
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }

  // Helper method to tap and wait
  static Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await waitForAnimations(tester);
  }

  // Helper method to enter text and wait
  static Future<void> enterTextAndWait(WidgetTester tester, Finder finder, String text) async {
    await tester.enterText(finder, text);
    await waitForAnimations(tester);
  }

  // Helper method to scroll and wait
  static Future<void> scrollAndWait(WidgetTester tester, Finder finder, Offset offset) async {
    await tester.drag(finder, offset);
    await waitForAnimations(tester);
  }

  // Helper method to verify text is present
  static void expectTextPresent(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  // Helper method to verify text is not present
  static void expectTextNotPresent(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }

  // Helper method to verify widget is present
  static void expectWidgetPresent(WidgetTester tester, Widget widget) {
    expect(find.byWidget(widget), findsOneWidget);
  }

  // Helper method to verify icon is present
  static void expectIconPresent(WidgetTester tester, IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  // Helper method to complete a game level
  static Future<void> completeGameLevel(WidgetTester tester, String correctAnswer) async {
    for (int i = 0; i < 5; i++) {
      await tester.pump(mediumDelay);
      await waitForAnimations(tester);
      
      if (find.byType(TextField).evaluate().isNotEmpty) {
        await enterTextAndWait(tester, find.byType(TextField), correctAnswer);
        await tapAndWait(tester, find.byIcon(Icons.send));
      }
    }
  }

  // Helper method to navigate to a specific tab
  static Future<void> navigateToTab(WidgetTester tester, IconData icon) async {
    await tapAndWait(tester, find.byIcon(icon));
  }

  // Helper method to navigate to a game
  static Future<void> navigateToGame(WidgetTester tester, String gameName) async {
    await navigateToTab(tester, Icons.videogame_asset);
    await tapAndWait(tester, find.text(gameName));
    await tapAndWait(tester, find.text('Level 1'));
  }

  // Helper method to set screen size
  static Future<void> setScreenSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    await waitForAnimations(tester);
  }

  // Helper method to reset screen size
  static Future<void> resetScreenSize(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(null);
    await waitForAnimations(tester);
  }

  // Helper method to wait for dialog
  static Future<void> waitForDialog(WidgetTester tester) async {
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  }

  // Helper method to dismiss dialog
  static Future<void> dismissDialog(WidgetTester tester) async {
    await tapAndWait(tester, find.text('Continue'));
  }

  // Helper method to check if snackbar is shown
  static void expectSnackBarPresent(WidgetTester tester, String message) {
    expect(find.text(message), findsOneWidget);
  }

  // Helper method to wait for loading to complete
  static Future<void> waitForLoading(WidgetTester tester) async {
    await tester.pumpAndSettle();
    // Wait for any loading indicators to disappear
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
      await tester.pump(shortDelay);
    }
  }
}

// Common test setup
class IntegrationTestSetup {
  static Future<void> setUpTest() async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }

  static Future<void> tearDownTest() async {
    // Clean up any test data
  }
} 