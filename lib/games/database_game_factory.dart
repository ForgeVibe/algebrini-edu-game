import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/database_models.dart';
import 'base_game.dart';
import 'recursive_sequences_game.dart';
import 'simple_equations_game.dart';
import 'factorization_game.dart';

class DatabaseGameFactory {
  static final GameDataService _gameDataService = GameDataService();
  static bool _isInitialized = false;

  /// Initialize the database connection
  static Future<void> initialize() async {
    if (!_isInitialized) {
      await _gameDataService.initialize();
      _isInitialized = true;
    }
  }

  /// Create a game instance with database data
  static Future<BaseGame> createGame(String gameId) async {
    await initialize();
    
    // Get game data from database
    final game = await _gameDataService.getGame(gameId);
    if (game == null) {
      throw ArgumentError('Game not found in database: $gameId');
    }

    // Create the appropriate game instance
    switch (gameId) {
      case 'recursive-sequences':
        return RecursiveSequencesGame.withDatabase(_gameDataService);
      case 'simple-equations':
        return SimpleEquationsGame.withDatabase(_gameDataService);
      case 'factorization-fun':
        return FactorizationGame.withDatabase(_gameDataService);
      default:
        throw ArgumentError('Unknown game ID: $gameId');
    }
  }

  /// Get all available games from database
  static Future<List<Game>> getAvailableGames() async {
    await initialize();
    return await _gameDataService.getGames();
  }

  /// Get game titles from database
  static Future<Map<String, String>> getGameTitles() async {
    final games = await getAvailableGames();
    return Map.fromEntries(
      games.map((game) => MapEntry(game.id, game.name))
    );
  }

  /// Get game descriptions from database
  static Future<Map<String, String>> getGameDescriptions() async {
    final games = await getAvailableGames();
    return Map.fromEntries(
      games.map((game) => MapEntry(game.id, game.description ?? 'No description available'))
    );
  }

  /// Get levels for a specific game
  static Future<List<Level>> getGameLevels(String gameId) async {
    await initialize();
    return await _gameDataService.getLevels(gameId);
  }

  /// Get challenges for a specific level
  static Future<List<Challenge>> getLevelChallenges(String levelId) async {
    await initialize();
    return await _gameDataService.getChallenges(levelId);
  }

  /// Get a random challenge for a level
  static Future<Challenge?> getRandomChallenge(String levelId) async {
    await initialize();
    return await _gameDataService.getRandomChallenge(levelId);
  }

  /// Get user progress for a game
  static Future<List<UserProgress>> getUserProgress(String userId, String gameId) async {
    await initialize();
    return await _gameDataService.getUserProgress(userId, gameId);
  }

  /// Save user progress
  static Future<bool> saveUserProgress({
    required String userId,
    required String gameId,
    required String levelId,
    required int score,
    required bool completed,
    int? timeSeconds,
    int attempts = 1,
  }) async {
    await initialize();
    return await _gameDataService.saveUserProgress(
      userId: userId,
      gameId: gameId,
      levelId: levelId,
      score: score,
      completed: completed,
      timeSeconds: timeSeconds,
      attempts: attempts,
    );
  }

  /// Check if user has completed a level
  static Future<bool> hasUserCompletedLevel(String userId, String levelId) async {
    await initialize();
    return await _gameDataService.hasUserCompletedLevel(userId, levelId);
  }

  /// Get user's highest score for a level
  static Future<int> getUserHighestScore(String userId, String levelId) async {
    await initialize();
    return await _gameDataService.getUserHighestScore(userId, levelId);
  }

  /// Get user's completion percentage for a game
  static Future<double> getUserGameCompletionPercentage(String userId, String gameId) async {
    await initialize();
    return await _gameDataService.getUserGameCompletionPercentage(userId, gameId);
  }

  /// Check if a level is unlocked for a user
  static Future<bool> isLevelUnlocked(String userId, String gameId, int levelNumber) async {
    await initialize();
    return await _gameDataService.isLevelUnlocked(userId, gameId, levelNumber);
  }

  /// Get recommended next level for user
  static Future<Level?> getRecommendedNextLevel(String userId, String gameId) async {
    await initialize();
    return await _gameDataService.getRecommendedNextLevel(userId, gameId);
  }

  /// Get user's total score for a game
  static Future<int> getUserTotalScore(String userId, String gameId) async {
    await initialize();
    return await _gameDataService.getUserTotalScore(userId, gameId);
  }

  /// Get user's total play time for a game
  static Future<int> getUserTotalPlayTime(String userId, String gameId) async {
    await initialize();
    return await _gameDataService.getUserTotalPlayTime(userId, gameId);
  }

  /// Dispose of database connections
  static Future<void> dispose() async {
    if (_isInitialized) {
      await _gameDataService.dispose();
      _isInitialized = false;
    }
  }
} 