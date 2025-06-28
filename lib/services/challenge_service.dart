import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'rewards_service.dart';
import 'analytics_service.dart';

class ChallengeService {
  static const String _dailyChallengeKey = 'dailyChallenge';
  static const String _weeklyChallengeKey = 'weeklyChallenge';
  static const String _challengeHistoryKey = 'challengeHistory';
  static const String _lastChallengeDateKey = 'lastChallengeDate';
  static const String _lastWeeklyChallengeDateKey = 'lastWeeklyChallengeDate';

  // Challenge types and their configurations
  static const Map<String, Map<String, dynamic>> _challengeTypes = {
    'speed_run': {
      'title': 'Speed Run',
      'description': 'Complete 5 questions in under 2 minutes',
      'icon': '⚡',
      'color': 'orange',
      'reward': {'coins': 10, 'stars': 2},
      'requirements': {'questions': 5, 'timeLimit': 120},
    },
    'perfect_score': {
      'title': 'Perfect Score',
      'description': 'Get 5 correct answers in a row',
      'icon': '🎯',
      'color': 'gold',
      'reward': {'coins': 15, 'stars': 3},
      'requirements': {'streak': 5},
    },
    'level_master': {
      'title': 'Level Master',
      'description': 'Complete 3 different levels',
      'icon': '🏆',
      'color': 'purple',
      'reward': {'coins': 20, 'stars': 4},
      'requirements': {'levels': 3},
    },
    'game_explorer': {
      'title': 'Game Explorer',
      'description': 'Play all 3 mini-games today',
      'icon': '🎮',
      'color': 'blue',
      'reward': {'coins': 12, 'stars': 2},
      'requirements': {'games': 3},
    },
    'accuracy_champion': {
      'title': 'Accuracy Champion',
      'description': 'Maintain 90% accuracy for 10 questions',
      'icon': '📊',
      'color': 'green',
      'reward': {'coins': 18, 'stars': 3},
      'requirements': {'accuracy': 90, 'questions': 10},
    },
  };

  // Weekly challenge types
  static const Map<String, Map<String, dynamic>> _weeklyChallengeTypes = {
    'weekly_streak': {
      'title': 'Weekly Streak',
      'description': 'Play for 5 consecutive days',
      'icon': '🔥',
      'color': 'red',
      'reward': {'coins': 50, 'stars': 10},
      'requirements': {'days': 5},
    },
    'weekly_master': {
      'title': 'Weekly Master',
      'description': 'Complete all levels in one game',
      'icon': '👑',
      'color': 'purple',
      'reward': {'coins': 75, 'stars': 15},
      'requirements': {'completeGame': true},
    },
    'weekly_explorer': {
      'title': 'Weekly Explorer',
      'description': 'Play 20 games this week',
      'icon': '🗺️',
      'color': 'teal',
      'reward': {'coins': 60, 'stars': 12},
      'requirements': {'games': 20},
    },
  };

  // Get current daily challenge
  static Future<Map<String, dynamic>?> getCurrentDailyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastChallengeDate = prefs.getString(_lastChallengeDateKey);
    
    // Generate new challenge if it's a new day
    if (lastChallengeDate != today) {
      final newChallenge = _generateDailyChallenge();
      await prefs.setString(_dailyChallengeKey, jsonEncode(newChallenge));
      await prefs.setString(_lastChallengeDateKey, today);
      return newChallenge;
    }
    
    // Return existing challenge
    final challengeStr = prefs.getString(_dailyChallengeKey);
    if (challengeStr != null) {
      return Map<String, dynamic>.from(jsonDecode(challengeStr));
    }
    
    return null;
  }

  // Get current weekly challenge
  static Future<Map<String, dynamic>?> getCurrentWeeklyChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = weekStart.toIso8601String().split('T')[0];
    final lastWeeklyDate = prefs.getString(_lastWeeklyChallengeDateKey);
    
    // Generate new challenge if it's a new week
    if (lastWeeklyDate != weekStartStr) {
      final newChallenge = _generateWeeklyChallenge();
      await prefs.setString(_weeklyChallengeKey, jsonEncode(newChallenge));
      await prefs.setString(_lastWeeklyChallengeDateKey, weekStartStr);
      return newChallenge;
    }
    
    // Return existing challenge
    final challengeStr = prefs.getString(_weeklyChallengeKey);
    if (challengeStr != null) {
      return Map<String, dynamic>.from(jsonDecode(challengeStr));
    }
    
    return null;
  }

  // Generate a random daily challenge
  static Map<String, dynamic> _generateDailyChallenge() {
    final random = Random();
    final challengeTypes = _challengeTypes.keys.toList();
    final selectedType = challengeTypes[random.nextInt(challengeTypes.length)];
    final challengeConfig = _challengeTypes[selectedType]!;
    
    return {
      'id': '${selectedType}_${DateTime.now().millisecondsSinceEpoch}',
      'type': selectedType,
      'title': challengeConfig['title'],
      'description': challengeConfig['description'],
      'icon': challengeConfig['icon'],
      'color': challengeConfig['color'],
      'reward': challengeConfig['reward'],
      'requirements': challengeConfig['requirements'],
      'progress': 0,
      'completed': false,
      'claimed': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Generate a random weekly challenge
  static Map<String, dynamic> _generateWeeklyChallenge() {
    final random = Random();
    final challengeTypes = _weeklyChallengeTypes.keys.toList();
    final selectedType = challengeTypes[random.nextInt(challengeTypes.length)];
    final challengeConfig = _weeklyChallengeTypes[selectedType]!;
    
    return {
      'id': '${selectedType}_${DateTime.now().millisecondsSinceEpoch}',
      'type': selectedType,
      'title': challengeConfig['title'],
      'description': challengeConfig['description'],
      'icon': challengeConfig['icon'],
      'color': challengeConfig['color'],
      'reward': challengeConfig['reward'],
      'requirements': challengeConfig['requirements'],
      'progress': 0,
      'completed': false,
      'claimed': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Update challenge progress
  static Future<void> updateChallengeProgress(String gameType, Map<String, dynamic> gameData) async {
    final dailyChallenge = await getCurrentDailyChallenge();
    final weeklyChallenge = await getCurrentWeeklyChallenge();
    
    if (dailyChallenge != null && !dailyChallenge['completed']) {
      await _updateDailyChallengeProgress(dailyChallenge, gameType, gameData);
    }
    
    if (weeklyChallenge != null && !weeklyChallenge['completed']) {
      await _updateWeeklyChallengeProgress(weeklyChallenge, gameType, gameData);
    }
  }

  // Update daily challenge progress
  static Future<void> _updateDailyChallengeProgress(
    Map<String, dynamic> challenge, 
    String gameType, 
    Map<String, dynamic> gameData
  ) async {
    final type = challenge['type'];
    var progress = challenge['progress'] as int;
    var completed = challenge['completed'] as bool;
    
    switch (type) {
      case 'speed_run':
        // Track time and questions completed
        final timeSpent = gameData['timeSpent'] ?? 0;
        final questionsCompleted = gameData['questionsCompleted'] ?? 0;
        if (timeSpent <= 120 && questionsCompleted >= 5) {
          progress = 100;
          completed = true;
        }
        break;
        
      case 'perfect_score':
        // Track streak
        final currentStreak = gameData['currentStreak'] ?? 0;
        if (currentStreak >= 5) {
          progress = 100;
          completed = true;
        } else {
          progress = (currentStreak / 5 * 100).round();
        }
        break;
        
      case 'level_master':
        // Track levels completed
        final levelsCompleted = gameData['levelsCompleted'] ?? 0;
        if (levelsCompleted >= 3) {
          progress = 100;
          completed = true;
        } else {
          progress = (levelsCompleted / 3 * 100).round();
        }
        break;
        
      case 'game_explorer':
        // Track games played today
        final gamesPlayed = gameData['gamesPlayedToday'] ?? 0;
        if (gamesPlayed >= 3) {
          progress = 100;
          completed = true;
        } else {
          progress = (gamesPlayed / 3 * 100).round();
        }
        break;
        
      case 'accuracy_champion':
        // Track accuracy over questions
        final accuracy = gameData['accuracy'] ?? 0;
        final totalQuestions = gameData['totalQuestions'] ?? 0;
        if (accuracy >= 90 && totalQuestions >= 10) {
          progress = 100;
          completed = true;
        } else if (totalQuestions > 0) {
          progress = (accuracy / 90 * 100).round();
        }
        break;
    }
    
    // Update challenge
    challenge['progress'] = progress;
    challenge['completed'] = completed;
    
    // Save updated challenge
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyChallengeKey, jsonEncode(challenge));
    
    // Log analytics
    if (completed) {
      await AnalyticsService.logEvent('daily_challenge_completed', details: {
        'challengeType': type,
        'reward': challenge['reward'],
      });
    }
  }

  // Update weekly challenge progress
  static Future<void> _updateWeeklyChallengeProgress(
    Map<String, dynamic> challenge, 
    String gameType, 
    Map<String, dynamic> gameData
  ) async {
    final type = challenge['type'];
    var progress = challenge['progress'] as int;
    var completed = challenge['completed'] as bool;
    
    switch (type) {
      case 'weekly_streak':
        // Track consecutive days played
        final consecutiveDays = gameData['consecutiveDays'] ?? 0;
        if (consecutiveDays >= 5) {
          progress = 100;
          completed = true;
        } else {
          progress = (consecutiveDays / 5 * 100).round();
        }
        break;
        
      case 'weekly_master':
        // Track if all levels in a game are completed
        final allLevelsCompleted = gameData['allLevelsCompleted'] ?? false;
        if (allLevelsCompleted) {
          progress = 100;
          completed = true;
        }
        break;
        
      case 'weekly_explorer':
        // Track total games played this week
        final gamesPlayed = gameData['gamesPlayedThisWeek'] ?? 0;
        if (gamesPlayed >= 20) {
          progress = 100;
          completed = true;
        } else {
          progress = (gamesPlayed / 20 * 100).round();
        }
        break;
    }
    
    // Update challenge
    challenge['progress'] = progress;
    challenge['completed'] = completed;
    
    // Save updated challenge
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weeklyChallengeKey, jsonEncode(challenge));
    
    // Log analytics
    if (completed) {
      await AnalyticsService.logEvent('weekly_challenge_completed', details: {
        'challengeType': type,
        'reward': challenge['reward'],
      });
    }
  }

  // Claim challenge reward
  static Future<bool> claimChallengeReward(String challengeId, bool isWeekly) async {
    final prefs = await SharedPreferences.getInstance();
    final key = isWeekly ? _weeklyChallengeKey : _dailyChallengeKey;
    
    final challengeStr = prefs.getString(key);
    if (challengeStr == null) return false;
    
    final challenge = Map<String, dynamic>.from(jsonDecode(challengeStr));
    
    if (challenge['id'] != challengeId || 
        !challenge['completed'] || 
        challenge['claimed']) {
      return false;
    }
    
    // Award rewards
    final reward = challenge['reward'] as Map<String, dynamic>;
    await RewardsService.addCoins(reward['coins'] ?? 0);
    await RewardsService.addStars(reward['stars'] ?? 0);
    
    // Mark as claimed
    challenge['claimed'] = true;
    await prefs.setString(key, jsonEncode(challenge));
    
    // Add to history
    await _addToHistory(challenge, isWeekly);
    
    // Log analytics
    await AnalyticsService.logEvent('challenge_reward_claimed', details: {
      'challengeId': challengeId,
      'isWeekly': isWeekly,
      'reward': reward,
    });
    
    return true;
  }

  // Add completed challenge to history
  static Future<void> _addToHistory(Map<String, dynamic> challenge, bool isWeekly) async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = prefs.getString(_challengeHistoryKey) ?? '[]';
    final history = List<Map<String, dynamic>>.from(
      jsonDecode(historyStr).map((e) => Map<String, dynamic>.from(e))
    );
    
    history.add({
      ...challenge,
      'completedAt': DateTime.now().toIso8601String(),
      'isWeekly': isWeekly,
    });
    
    // Keep only last 50 challenges
    if (history.length > 50) {
      history.removeRange(0, history.length - 50);
    }
    
    await prefs.setString(_challengeHistoryKey, jsonEncode(history));
  }

  // Get challenge history
  static Future<List<Map<String, dynamic>>> getChallengeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = prefs.getString(_challengeHistoryKey) ?? '[]';
    return List<Map<String, dynamic>>.from(
      jsonDecode(historyStr).map((e) => Map<String, dynamic>.from(e))
    );
  }

  // Get challenge statistics
  static Future<Map<String, dynamic>> getChallengeStats() async {
    final history = await getChallengeHistory();
    final dailyCompleted = history.where((c) => !c['isWeekly']).length;
    final weeklyCompleted = history.where((c) => c['isWeekly']).length;
    final totalRewards = history.fold<Map<String, int>>(
      {'coins': 0, 'stars': 0},
      (acc, challenge) {
        final reward = challenge['reward'] as Map<String, dynamic>;
        acc['coins'] = (acc['coins'] ?? 0) + ((reward['coins'] ?? 0) as int);
        acc['stars'] = (acc['stars'] ?? 0) + ((reward['stars'] ?? 0) as int);
        return acc;
      }
    );
    
    return {
      'dailyCompleted': dailyCompleted,
      'weeklyCompleted': weeklyCompleted,
      'totalRewards': totalRewards,
    };
  }

  // Reset all challenge data (for testing)
  static Future<void> resetChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyChallengeKey);
    await prefs.remove(_weeklyChallengeKey);
    await prefs.remove(_challengeHistoryKey);
    await prefs.remove(_lastChallengeDateKey);
    await prefs.remove(_lastWeeklyChallengeDateKey);
  }
} 