import 'package:shared_preferences/shared_preferences.dart';
import 'rewards_service.dart';
import 'analytics_service.dart';

class GameStatsService {
  static const String _totalGamesPlayedKey = 'totalGamesPlayed';
  static const String _correctAnswersKey = 'correctAnswers';
  static const String _totalAnswersKey = 'totalAnswers';
  static const String _sequencesCompletedKey = 'sequencesCompleted';
  static const String _equationsCompletedKey = 'equationsCompleted';
  static const String _currentStreakKey = 'currentStreak';
  static const String _bestStreakKey = 'bestStreak';
  static const String _lastPlayedKey = 'lastPlayed';

  static Future<void> recordAnswer(bool isCorrect, String gameType) async {
    final prefs = await SharedPreferences.getInstance();

    // Update basic stats
    final totalAnswers = (prefs.getInt(_totalAnswersKey) ?? 0) + 1;
    final correctAnswers =
        (prefs.getInt(_correctAnswersKey) ?? 0) + (isCorrect ? 1 : 0);

    await prefs.setInt(_totalAnswersKey, totalAnswers);
    await prefs.setInt(_correctAnswersKey, correctAnswers);

    // Update streak
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final bestStreak = prefs.getInt(_bestStreakKey) ?? 0;

    if (isCorrect) {
      final newStreak = currentStreak + 1;
      await prefs.setInt(_currentStreakKey, newStreak);
      if (newStreak > bestStreak) {
        await prefs.setInt(_bestStreakKey, newStreak);
      }
      // Award 1 coin for each correct answer
      await RewardsService.addCoins(1);
      await AnalyticsService.logEvent('correct_answer',
          details: {'gameType': gameType});
    } else {
      await prefs.setInt(_currentStreakKey, 0);
      await AnalyticsService.logEvent('incorrect_answer',
          details: {'gameType': gameType});
    }

    // Update last played
    final now = DateTime.now();
    await prefs.setString(
        _lastPlayedKey, '$gameType - ${now.toString().substring(0, 16)}');
  }

  static Future<void> recordGameCompletion(String gameType) async {
    final prefs = await SharedPreferences.getInstance();

    final totalGamesPlayed = (prefs.getInt(_totalGamesPlayedKey) ?? 0) + 1;
    await prefs.setInt(_totalGamesPlayedKey, totalGamesPlayed);

    if (gameType == 'sequences') {
      final sequencesCompleted =
          (prefs.getInt(_sequencesCompletedKey) ?? 0) + 1;
      await prefs.setInt(_sequencesCompletedKey, sequencesCompleted);
    } else if (gameType == 'equations') {
      final equationsCompleted =
          (prefs.getInt(_equationsCompletedKey) ?? 0) + 1;
      await prefs.setInt(_equationsCompletedKey, equationsCompleted);
    }
    // Award 5 stars for each game completion
    await RewardsService.addStars(5);
    await AnalyticsService.logEvent('game_completed',
        details: {'gameType': gameType});
  }

  static Future<Map<String, dynamic>> getStats() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'totalGamesPlayed': prefs.getInt(_totalGamesPlayedKey) ?? 0,
      'correctAnswers': prefs.getInt(_correctAnswersKey) ?? 0,
      'totalAnswers': prefs.getInt(_totalAnswersKey) ?? 0,
      'sequencesCompleted': prefs.getInt(_sequencesCompletedKey) ?? 0,
      'equationsCompleted': prefs.getInt(_equationsCompletedKey) ?? 0,
      'currentStreak': prefs.getInt(_currentStreakKey) ?? 0,
      'bestStreak': prefs.getInt(_bestStreakKey) ?? 0,
      'lastPlayed': prefs.getString(_lastPlayedKey) ?? 'Never',
    };
  }

  static Future<double> getAccuracy() async {
    final stats = await getStats();
    final totalAnswers = stats['totalAnswers'] as int;
    if (totalAnswers == 0) return 0.0;
    return (stats['correctAnswers'] as int) / totalAnswers * 100;
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await AnalyticsService.logEvent('progress_reset');
  }
}
