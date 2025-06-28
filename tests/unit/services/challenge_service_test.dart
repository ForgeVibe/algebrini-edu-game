import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/services/challenge_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ChallengeService', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('getCurrentDailyChallenge returns a challenge', () async {
      final challenge = await ChallengeService.getCurrentDailyChallenge();
      
      expect(challenge, isNotNull);
      expect(challenge!['title'], isNotEmpty);
      expect(challenge['description'], isNotEmpty);
      expect(challenge['icon'], isNotEmpty);
      expect(challenge['color'], isNotEmpty);
      expect(challenge['reward'], isA<Map<String, dynamic>>());
      expect(challenge['progress'], 0);
      expect(challenge['completed'], false);
      expect(challenge['claimed'], false);
    });

    test('getCurrentWeeklyChallenge returns a challenge', () async {
      final challenge = await ChallengeService.getCurrentWeeklyChallenge();
      
      expect(challenge, isNotNull);
      expect(challenge!['title'], isNotEmpty);
      expect(challenge['description'], isNotEmpty);
      expect(challenge['icon'], isNotEmpty);
      expect(challenge['color'], isNotEmpty);
      expect(challenge['reward'], isA<Map<String, dynamic>>());
      expect(challenge['progress'], 0);
      expect(challenge['completed'], false);
      expect(challenge['claimed'], false);
    });

    test('same daily challenge is returned for same day', () async {
      final challenge1 = await ChallengeService.getCurrentDailyChallenge();
      final challenge2 = await ChallengeService.getCurrentDailyChallenge();
      
      expect(challenge1!['id'], challenge2!['id']);
      expect(challenge1['title'], challenge2['title']);
    });

    test('same weekly challenge is returned for same week', () async {
      final challenge1 = await ChallengeService.getCurrentWeeklyChallenge();
      final challenge2 = await ChallengeService.getCurrentWeeklyChallenge();
      
      expect(challenge1!['id'], challenge2!['id']);
      expect(challenge1['title'], challenge2['title']);
    });

    test('updateChallengeProgress updates daily challenge progress', () async {
      final challenge = await ChallengeService.getCurrentDailyChallenge();
      final originalProgress = challenge!['progress'] as int;
      
      // Update progress for speed run challenge
      if (challenge['type'] == 'speed_run') {
        await ChallengeService.updateChallengeProgress('test-game', {
          'timeSpent': 100,
          'questionsCompleted': 5,
        });
        
        final updatedChallenge = await ChallengeService.getCurrentDailyChallenge();
        expect(updatedChallenge!['progress'], greaterThan(originalProgress));
      }
    });

    test('claimChallengeReward works for completed challenge', () async {
      // First, get a challenge
      final challenge = await ChallengeService.getCurrentDailyChallenge();
      
      // Manually mark it as completed (for testing)
      final prefs = await SharedPreferences.getInstance();
      final challengeData = Map<String, dynamic>.from(challenge!);
      challengeData['completed'] = true;
      challengeData['progress'] = 100;
      await prefs.setString('dailyChallenge', challengeData.toString());
      
      // Try to claim the reward
      final success = await ChallengeService.claimChallengeReward(
        challenge['id'], 
        false
      );
      
      expect(success, isTrue);
    });

    test('claimChallengeReward fails for incomplete challenge', () async {
      final challenge = await ChallengeService.getCurrentDailyChallenge();
      
      final success = await ChallengeService.claimChallengeReward(
        challenge!['id'], 
        false
      );
      
      expect(success, isFalse);
    });

    test('getChallengeStats returns correct statistics', () async {
      final stats = await ChallengeService.getChallengeStats();
      
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['dailyCompleted'], isA<int>());
      expect(stats['weeklyCompleted'], isA<int>());
      expect(stats['totalRewards'], isA<Map<String, dynamic>>());
      expect(stats['totalRewards']['coins'], isA<int>());
      expect(stats['totalRewards']['stars'], isA<int>());
    });

    test('getChallengeHistory returns empty list initially', () async {
      final history = await ChallengeService.getChallengeHistory();
      
      expect(history, isEmpty);
    });

    test('resetChallenges clears all challenge data', () async {
      // Create some challenge data
      await ChallengeService.getCurrentDailyChallenge();
      await ChallengeService.getCurrentWeeklyChallenge();
      
      // Reset challenges
      await ChallengeService.resetChallenges();
      
      // Verify data is cleared
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('dailyChallenge'), isNull);
      expect(prefs.getString('weeklyChallenge'), isNull);
      expect(prefs.getString('challengeHistory'), isNull);
    });
  });
} 