import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:algebrini_edu_game/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Algebrini Web App Tests', () {
    setUpAll(() async {
      // Set up web-specific configurations
    });

    testWidgets('Web app launches and is responsive', (WidgetTester tester) async {
      // Set a web-like screen size
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      // Verify web app loads correctly
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Challenges'), findsOneWidget);
    });

    testWidgets('Web navigation works with larger screen', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      // Test navigation on web
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();
      expect(find.text('Choose Your Game'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();
      expect(find.text('Daily'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.text('Your Progress'), findsOneWidget);
    });

    testWidgets('Web responsive design adapts to different screen sizes', (WidgetTester tester) async {
      // Test tablet size
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);

      // Test mobile size
      await tester.binding.setSurfaceSize(const Size(375, 667));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);

      // Test desktop size
      await tester.binding.setSurfaceSize(const Size(1920, 1080));
      await tester.pumpAndSettle();

      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('Web game interaction works with keyboard', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a game
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Test keyboard input
      await tester.enterText(find.byType(TextField), '7');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verify answer was submitted
      expect(find.text('Correct!'), findsOneWidget);
    });

    testWidgets('Web settings work correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Test web-specific settings
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);

      // Test font size slider
      final slider = find.byType(Slider);
      expect(slider, findsOneWidget);
    });

    testWidgets('Web challenges display correctly', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Test tab navigation
      await tester.tap(find.text('Daily'));
      await tester.pumpAndSettle();
      expect(find.text('Today\'s Challenge'), findsOneWidget);

      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.text('This Week\'s Challenge'), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Recent Challenges'), findsOneWidget);
    });

    testWidgets('Web progress analytics work', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      // Test export functionality
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
    });
  });
} 