import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LevelProgressionService {
  static const String _unlockedLevelsKey = 'unlockedLevels';
  static const String _levelScoresKey = 'levelScores';
  static const String _levelCompletionsKey = 'levelCompletions';
  static const String _achievementsKey = 'achievements';

  // Level unlock requirements
  static const Map<String, Map<int, Map<String, dynamic>>> _unlockRequirements = {
    'recursive-sequences': {
      1: {'type': 'always', 'requirement': null}, // Level 1 always unlocked
      2: {'type': 'score', 'requirement': 3, 'game': 'recursive-sequences', 'level': 1}, // Score 3+ on level 1
      3: {'type': 'score', 'requirement': 4, 'game': 'recursive-sequences', 'level': 2}, // Score 4+ on level 2
      4: {'type': 'completion', 'requirement': 2, 'game': 'recursive-sequences'}, // Complete 2 levels
      5: {'type': 'streak', 'requirement': 5, 'game': 'recursive-sequences'}, // 5 correct answers in a row
    },
    'simple-equations': {
      1: {'type': 'always', 'requirement': null},
      2: {'type': 'score', 'requirement': 3, 'game': 'simple-equations', 'level': 1},
      3: {'type': 'score', 'requirement': 4, 'game': 'simple-equations', 'level': 2},
      4: {'type': 'completion', 'requirement': 2, 'game': 'simple-equations'},
      5: {'type': 'streak', 'requirement': 5, 'game': 'simple-equations'},
    },
    'factorization-fun': {
      1: {'type': 'always', 'requirement': null},
      2: {'type': 'score', 'requirement': 3, 'game': 'factorization-fun', 'level': 1},
      3: {'type': 'score', 'requirement': 4, 'game': 'factorization-fun', 'level': 2},
      4: {'type': 'completion', 'requirement': 2, 'game': 'factorization-fun'},
      5: {'type': 'streak', 'requirement': 5, 'game': 'factorization-fun'},
    },
  };

  // Achievement definitions
  static const Map<String, Map<String, dynamic>> _achievements = {
    'first_level': {
      'title': 'First Steps',
      'description': 'Complete your first level',
      'icon': 'star',
      'color': 'green',
    },
    'perfect_score': {
      'title': 'Perfect Score',
      'description': 'Get a perfect score on any level',
      'icon': 'trophy',
      'color': 'gold',
    },
    'level_master': {
      'title': 'Level Master',
      'description': 'Complete all levels in a game',
      'icon': 'crown',
      'color': 'purple',
    },
    'streak_master': {
      'title': 'Streak Master',
      'description': 'Get 10 correct answers in a row',
      'icon': 'fire',
      'color': 'orange',
    },
    'speed_demon': {
      'title': 'Speed Demon',
      'description': 'Complete a level in under 30 seconds',
      'icon': 'bolt',
      'color': 'yellow',
    },
  };

  // Get unlocked levels for a specific game
  static Future<List<int>> getUnlockedLevels(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedStr = prefs.getString('${_unlockedLevelsKey}_$gameId') ?? '1'; // Level 1 always unlocked
    final unlockedList = unlockedStr.split(',').map((e) => int.tryParse(e) ?? 1).toList();
    return unlockedList;
  }

  // Check if a level is unlocked
  static Future<bool> isLevelUnlocked(String gameId, int level) async {
    final unlockedLevels = await getUnlockedLevels(gameId);
    return unlockedLevels.contains(level);
  }

  // Get the highest unlocked level for a game
  static Future<int> getHighestUnlockedLevel(String gameId) async {
    final unlockedLevels = await getUnlockedLevels(gameId);
    return unlockedLevels.isNotEmpty ? unlockedLevels.reduce((a, b) => a > b ? a : b) : 1;
  }

  // Record a level completion with score
  static Future<void> recordLevelCompletion(String gameId, int level, int score, {int? timeSeconds}) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Record score
    final scoresKey = '${_levelScoresKey}_$gameId';
    final scoresStr = prefs.getString(scoresKey) ?? '{}';
    final scores = Map<String, dynamic>.from(jsonDecode(scoresStr));
    scores[level.toString()] = score;
    await prefs.setString(scoresKey, jsonEncode(scores));
    
    // Record completion
    final completionsKey = '${_levelCompletionsKey}_$gameId';
    final completionsStr = prefs.getString(completionsKey) ?? '{}';
    final completions = Map<String, dynamic>.from(jsonDecode(completionsStr));
    completions[level.toString()] = {
      'completed': true,
      'score': score,
      'timeSeconds': timeSeconds,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(completionsKey, jsonEncode(completions));
    
    // Check for new level unlocks
    await _checkForNewUnlocks(gameId);
    
    // Check for achievements
    await _checkForAchievements(gameId, level, score, timeSeconds);
  }

  // Get level score
  static Future<int> getLevelScore(String gameId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final scoresKey = '${_levelScoresKey}_$gameId';
    final scoresStr = prefs.getString(scoresKey) ?? '{}';
    final scores = Map<String, dynamic>.from(jsonDecode(scoresStr));
    return scores[level.toString()] ?? 0;
  }

  // Get all level scores for a game
  static Future<Map<int, int>> getAllLevelScores(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final scoresKey = '${_levelScoresKey}_$gameId';
    final scoresStr = prefs.getString(scoresKey) ?? '{}';
    final scores = Map<String, dynamic>.from(jsonDecode(scoresStr));
    return scores.map((key, value) => MapEntry(int.parse(key), value as int));
  }

  // Get level completion data
  static Future<Map<String, dynamic>?> getLevelCompletion(String gameId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final completionsKey = '${_levelCompletionsKey}_$gameId';
    final completionsStr = prefs.getString(completionsKey) ?? '{}';
    final completions = Map<String, dynamic>.from(jsonDecode(completionsStr));
    return completions[level.toString()];
  }

  // Get all achievements
  static Future<List<String>> getAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final achievementsStr = prefs.getString(_achievementsKey) ?? '';
    return achievementsStr.isEmpty ? [] : achievementsStr.split(',');
  }

  // Get achievement details
  static Map<String, dynamic> getAchievementDetails(String achievementId) {
    return _achievements[achievementId] ?? {};
  }

  // Get all achievement details
  static Map<String, Map<String, dynamic>> getAllAchievementDetails() {
    return Map.from(_achievements);
  }

  // Check for new level unlocks
  static Future<void> _checkForNewUnlocks(String gameId) async {
    final requirements = _unlockRequirements[gameId];
    if (requirements == null) return;
    
    final currentUnlocked = await getUnlockedLevels(gameId);
    final newUnlocked = <int>[];
    
    for (final entry in requirements.entries) {
      final level = entry.key;
      final requirement = entry.value;
      
      if (currentUnlocked.contains(level)) continue; // Already unlocked
      
      bool shouldUnlock = false;
      
      switch (requirement['type']) {
        case 'always':
          shouldUnlock = true;
          break;
        case 'score':
          final targetLevel = requirement['level'] as int;
          final targetScore = requirement['requirement'] as int;
          final score = await getLevelScore(gameId, targetLevel);
          shouldUnlock = score >= targetScore;
          break;
        case 'completion':
          final targetCompletions = requirement['requirement'] as int;
          final completions = await _getCompletedLevelsCount(gameId);
          shouldUnlock = completions >= targetCompletions;
          break;
        case 'streak':
          final targetStreak = requirement['requirement'] as int;
          final currentStreak = await _getCurrentStreak(gameId);
          shouldUnlock = currentStreak >= targetStreak;
          break;
      }
      
      if (shouldUnlock) {
        newUnlocked.add(level);
      }
    }
    
    if (newUnlocked.isNotEmpty) {
      final allUnlocked = [...currentUnlocked, ...newUnlocked];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${_unlockedLevelsKey}_$gameId', allUnlocked.join(','));
    }
  }

  // Check for achievements
  static Future<void> _checkForAchievements(String gameId, int level, int score, int? timeSeconds) async {
    final currentAchievements = await getAchievements();
    final newAchievements = <String>[];
    
    // First level completion
    if (!currentAchievements.contains('first_level')) {
      newAchievements.add('first_level');
    }
    
    // Perfect score (score of 5)
    if (score == 5 && !currentAchievements.contains('perfect_score')) {
      newAchievements.add('perfect_score');
    }
    
    // Speed demon (under 30 seconds)
    if (timeSeconds != null && timeSeconds < 30 && !currentAchievements.contains('speed_demon')) {
      newAchievements.add('speed_demon');
    }
    
    // Level master (all levels completed)
    if (!currentAchievements.contains('level_master')) {
      final allLevels = _unlockRequirements[gameId]?.keys.toList() ?? [];
      bool allCompleted = true;
      for (final lvl in allLevels) {
        final completion = await getLevelCompletion(gameId, lvl);
        if (completion == null || completion['completed'] != true) {
          allCompleted = false;
          break;
        }
      }
      if (allCompleted) {
        newAchievements.add('level_master');
      }
    }
    
    // Add new achievements
    if (newAchievements.isNotEmpty) {
      final allAchievements = [...currentAchievements, ...newAchievements];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_achievementsKey, allAchievements.join(','));
    }
  }

  // Helper methods
  static Future<int> _getCompletedLevelsCount(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final completionsKey = '${_levelCompletionsKey}_$gameId';
    final completionsStr = prefs.getString(completionsKey) ?? '{}';
    final completions = Map<String, dynamic>.from(jsonDecode(completionsStr));
    return completions.values.where((c) => c['completed'] == true).length;
  }

  static Future<int> _getCurrentStreak(String gameId) async {
    // This would need to be implemented based on the current streak tracking
    // For now, return 0 as a placeholder
    return 0;
  }

  // Reset all progress for a game
  static Future<void> resetGameProgress(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_unlockedLevelsKey}_$gameId');
    await prefs.remove('${_levelScoresKey}_$gameId');
    await prefs.remove('${_levelCompletionsKey}_$gameId');
  }

  // Reset all progress
  static Future<void> resetAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_unlockedLevelsKey) || 
          key.startsWith(_levelScoresKey) || 
          key.startsWith(_levelCompletionsKey) ||
          key == _achievementsKey) {
        await prefs.remove(key);
      }
    }
  }
} 