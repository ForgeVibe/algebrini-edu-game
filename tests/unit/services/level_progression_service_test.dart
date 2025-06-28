import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:algebrini_edu_game/services/level_progression_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LevelProgressionService.resetAllProgress();
  });

  group('LevelProgressionService', () {
    test('Initial unlocked levels should be only level 1', () async {
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels('recursive-sequences');
      expect(unlockedLevels, [1]);
    });

    test('Level 1 should always be unlocked', () async {
      final isUnlocked = await LevelProgressionService.isLevelUnlocked('recursive-sequences', 1);
      expect(isUnlocked, isTrue);
    });

    test('Higher levels should be locked initially', () async {
      final isUnlocked = await LevelProgressionService.isLevelUnlocked('recursive-sequences', 2);
      expect(isUnlocked, isFalse);
    });

    test('Recording level completion should save score', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      final score = await LevelProgressionService.getLevelScore('recursive-sequences', 1);
      expect(score, 4);
    });

    test('Recording level completion should unlock next level if score is high enough', () async {
      // Level 2 requires score 3+ on level 1
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels('recursive-sequences');
      expect(unlockedLevels, contains(2));
    });

    test('Recording level completion should not unlock next level if score is too low', () async {
      // Level 2 requires score 3+ on level 1
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 2);
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels('recursive-sequences');
      expect(unlockedLevels, isNot(contains(2)));
    });

    test('Getting all level scores should return all recorded scores', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 2, 5);
      final scores = await LevelProgressionService.getAllLevelScores('recursive-sequences');
      expect(scores[1], 4);
      expect(scores[2], 5);
    });

    test('Getting level completion data should return completion details', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4, timeSeconds: 30);
      final completion = await LevelProgressionService.getLevelCompletion('recursive-sequences', 1);
      expect(completion?['completed'], isTrue);
      expect(completion?['score'], 4);
      expect(completion?['timeSeconds'], 30);
      expect(completion?['timestamp'], isNotNull);
    });

    test('Getting achievements should return empty list initially', () async {
      final achievements = await LevelProgressionService.getAchievements();
      expect(achievements, isEmpty);
    });

    test('Recording first level completion should unlock first_level achievement', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 3);
      final achievements = await LevelProgressionService.getAchievements();
      expect(achievements, contains('first_level'));
    });

    test('Recording perfect score should unlock perfect_score achievement', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 5);
      final achievements = await LevelProgressionService.getAchievements();
      expect(achievements, contains('perfect_score'));
    });

    test('Getting achievement details should return correct information', () async {
      final details = LevelProgressionService.getAchievementDetails('first_level');
      expect(details['title'], 'First Steps');
      expect(details['description'], 'Complete your first level');
      expect(details['icon'], 'star');
      expect(details['color'], 'green');
    });

    test('Getting all achievement details should return all achievements', () async {
      final allDetails = LevelProgressionService.getAllAchievementDetails();
      expect(allDetails, contains('first_level'));
      expect(allDetails, contains('perfect_score'));
      expect(allDetails, contains('level_master'));
      expect(allDetails, contains('streak_master'));
      expect(allDetails, contains('speed_demon'));
    });

    test('Resetting game progress should clear all data for that game', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      await LevelProgressionService.resetGameProgress('recursive-sequences');
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels('recursive-sequences');
      final scores = await LevelProgressionService.getAllLevelScores('recursive-sequences');
      expect(unlockedLevels, [1]); // Level 1 should still be unlocked
      expect(scores, isEmpty);
    });

    test('Resetting all progress should clear all data', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      await LevelProgressionService.recordLevelCompletion('simple-equations', 1, 3);
      await LevelProgressionService.resetAllProgress();
      
      final recursiveLevels = await LevelProgressionService.getUnlockedLevels('recursive-sequences');
      final equationLevels = await LevelProgressionService.getUnlockedLevels('simple-equations');
      final achievements = await LevelProgressionService.getAchievements();
      
      expect(recursiveLevels, [1]);
      expect(equationLevels, [1]);
      expect(achievements, isEmpty);
    });

    test('Getting highest unlocked level should return correct level', () async {
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 1, 4);
      await LevelProgressionService.recordLevelCompletion('recursive-sequences', 2, 4);
      final highestLevel = await LevelProgressionService.getHighestUnlockedLevel('recursive-sequences');
      expect(highestLevel, 4);
    });

    test('Getting highest unlocked level should return 1 for new game', () async {
      final highestLevel = await LevelProgressionService.getHighestUnlockedLevel('new-game');
      expect(highestLevel, 1);
    });
  });
} 