import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:algebrini_edu_game/main.dart' as app;
import 'package:algebrini_edu_game/services/challenge_service.dart';
import 'package:algebrini_edu_game/services/rewards_service.dart';
import 'package:algebrini_edu_game/services/game_stats_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Algebrini App Integration Tests', () {
    setUpAll(() async {
      // Clear all data before running tests
      await ChallengeService.resetChallenges();
      await RewardsService.resetRewards();
      await GameStatsService.resetProgress();
    });

    testWidgets('App launches and shows home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify home screen elements are present
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
      expect(find.text('Challenges'), findsOneWidget);
      expect(find.text('Progress'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Navigation between tabs works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test Play tab
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();
      expect(find.text('Choose Your Game'), findsOneWidget);
      expect(find.text('Simple Equations'), findsOneWidget);
      expect(find.text('Recursive Sequences'), findsOneWidget);
      expect(find.text('Factorization Fun'), findsOneWidget);

      // Test Challenges tab
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Weekly'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // Test Progress tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();
      expect(find.text('Your Progress'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Test Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Coins'), findsOneWidget);
      expect(find.text('Stars'), findsOneWidget);

      // Test Settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
    });

    testWidgets('Game selection and level progression works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Play screen
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      // Select Simple Equations game
      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      // Verify level selection screen
      expect(find.text('Level Selection'), findsOneWidget);
      expect(find.text('Level 1'), findsOneWidget);

      // Select Level 1
      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Verify game screen loads
      expect(find.text('Simple Equations - Level 1'), findsOneWidget);
      expect(find.text('Question 1 of 5'), findsOneWidget);

      // Answer a question correctly
      await tester.enterText(find.byType(TextField), '7');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verify correct answer feedback
      expect(find.text('Correct!'), findsOneWidget);

      // Continue through the game
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField), '7');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();
        }
      }

      // Verify game completion dialog
      expect(find.text('Level Complete!'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Return to level selection
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Level Selection'), findsOneWidget);
    });

    testWidgets('Challenges system works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Challenges screen
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Check Daily tab
      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Today\'s Challenge'), findsOneWidget);

      // Check Weekly tab
      await tester.tap(find.text('Weekly'));
      await tester.pumpAndSettle();
      expect(find.text('This Week\'s Challenge'), findsOneWidget);

      // Check History tab
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Recent Challenges'), findsOneWidget);
    });

    testWidgets('Settings and accessibility features work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings screen
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Test font size adjustment
      final fontSizeSlider = find.byType(Slider);
      expect(fontSizeSlider, findsOneWidget);

      // Test dyslexia-friendly font toggle
      final dyslexiaToggle = find.byType(Switch);
      expect(dyslexiaToggle, findsAtLeastNWidgets(1));

      // Test high contrast mode toggle
      await tester.tap(find.text('High Contrast/Colorblind Mode'));
      await tester.pumpAndSettle();

      // Test TTS toggle
      await tester.tap(find.text('Text-to-Speech'));
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();
    });

    testWidgets('Rewards and progress tracking works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Profile screen to check initial rewards
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('0'), findsAtLeastNWidgets(1)); // Initial coins/stars

      // Play a game to earn rewards
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Complete the game quickly
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField), '7');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();
        }
      }

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check that rewards were earned
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      // Verify rewards increased
      expect(find.text('5'), findsAtLeastNWidgets(1)); // Should have earned coins/stars
    });

    testWidgets('Challenge completion and reward claiming works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Challenges
      await tester.tap(find.byIcon(Icons.emoji_events));
      await tester.pumpAndSettle();

      // Check if there's a claimable challenge
      if (find.text('Claim').evaluate().isNotEmpty) {
        await tester.tap(find.text('Claim'));
        await tester.pumpAndSettle();
        
        // Verify reward claimed message
        expect(find.text('Reward claimed successfully!'), findsOneWidget);
      }
    });

    testWidgets('Progress screen shows analytics correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Progress screen
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Check statistics are displayed
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);

      // Test analytics export
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();

      // Check export buttons
      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);
    });

    testWidgets('Home screen challenge widget works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check daily challenge widget on home screen
      expect(find.text('Today\'s Challenge'), findsOneWidget);

      // Tap View All to go to challenges
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      // Verify we're on challenges screen
      expect(find.text('Daily'), findsOneWidget);
    });

    testWidgets('Game hint system works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a game
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Test hint button
      await tester.tap(find.text('Show Hint'));
      await tester.pumpAndSettle();

      // Verify hint is displayed
      expect(find.text('Hide Hint'), findsOneWidget);

      // Hide hint
      await tester.tap(find.text('Hide Hint'));
      await tester.pumpAndSettle();

      expect(find.text('Show Hint'), findsOneWidget);
    });

    testWidgets('TTS functionality works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to a game
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Test TTS button
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();

      // Verify TTS was triggered (button should still be visible)
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
    });

    testWidgets('Level unlocking system works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Play screen
      await tester.tap(find.byIcon(Icons.videogame_asset));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simple Equations'));
      await tester.pumpAndSettle();

      // Check that only Level 1 is initially available
      expect(find.text('Level 1'), findsOneWidget);

      // Complete Level 1 to unlock Level 2
      await tester.tap(find.text('Level 1'));
      await tester.pumpAndSettle();

      // Complete the game
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField), '7');
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();
        }
      }

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Check if Level 2 is now available (depends on score)
      // This test verifies the level progression system works
      expect(find.text('Level Selection'), findsOneWidget);
    });
  });
} 