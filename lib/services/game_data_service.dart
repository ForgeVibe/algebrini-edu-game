import 'package:uuid/uuid.dart';
import '../models/database_models.dart';
import 'database_service.dart';

class GameDataService {
  static final GameDataService _instance = GameDataService._internal();
  factory GameDataService() => _instance;
  GameDataService._internal();

  final DatabaseService _dbService = DatabaseService();
  final Uuid _uuid = Uuid();

  // Cache for performance
  List<Game>? _gamesCache;
  List<Chapter>? _chaptersCache;
  List<Realm>? _realmsCache;
  List<Achievement>? _achievementsCache;
  Map<String, List<Level>> _levelsCache = {};
  Map<String, List<Challenge>> _challengesCache = {};

  /// Initialize the service and database connection
  Future<void> initialize() async {
    await _dbService.initialize();
    await _loadInitialData();
  }

  /// Load initial data into cache
  Future<void> _loadInitialData() async {
    try {
      _gamesCache = await _dbService.getGames();
      _chaptersCache = await _dbService.getChapters();
      _realmsCache = await _dbService.getRealms();
      _achievementsCache = await _dbService.getAchievements();
      print('Initial data loaded successfully');
    } catch (e) {
      print('Error loading initial data: $e');
    }
  }

  /// Clear all caches
  void clearCache() {
    _gamesCache = null;
    _chaptersCache = null;
    _realmsCache = null;
    _achievementsCache = null;
    _levelsCache.clear();
    _challengesCache.clear();
  }

  // ===== GAMES =====

  /// Get all available games
  Future<List<Game>> getGames() async {
    if (_gamesCache != null) {
      return _gamesCache!;
    }

    _gamesCache = await _dbService.getGames();
    return _gamesCache!;
  }

  /// Get a specific game by ID
  Future<Game?> getGame(String gameId) async {
    final games = await getGames();
    return games.firstWhere(
      (game) => game.id == gameId,
      orElse: () => throw Exception('Game not found: $gameId'),
    );
  }

  /// Get games by IDs
  Future<List<Game>> getGamesByIds(List<String> gameIds) async {
    final games = await getGames();
    return games.where((game) => gameIds.contains(game.id)).toList();
  }

  // ===== LEVELS =====

  /// Get all levels for a game
  Future<List<Level>> getLevels(String gameId) async {
    if (_levelsCache.containsKey(gameId)) {
      return _levelsCache[gameId]!;
    }

    final levels = await _dbService.getLevelsByGameId(gameId);
    _levelsCache[gameId] = levels;
    return levels;
  }

  /// Get a specific level
  Future<Level?> getLevel(String gameId, int levelNumber) async {
    final levels = await getLevels(gameId);
    return levels.firstWhere(
      (level) => level.levelNumber == levelNumber,
      orElse: () =>
          throw Exception('Level not found: $gameId level $levelNumber'),
    );
  }

  /// Get levels by difficulty
  Future<List<Level>> getLevelsByDifficulty(
      String gameId, DifficultyLevel difficulty) async {
    final levels = await getLevels(gameId);
    return levels.where((level) => level.difficulty == difficulty).toList();
  }

  // ===== CHALLENGES =====

  /// Get all challenges for a level
  Future<List<Challenge>> getChallenges(String levelId) async {
    if (_challengesCache.containsKey(levelId)) {
      return _challengesCache[levelId]!;
    }

    final challenges = await _dbService.getChallengesByLevelId(levelId);
    _challengesCache[levelId] = challenges;
    return challenges;
  }

  /// Get a random challenge for a level
  Future<Challenge?> getRandomChallenge(String levelId) async {
    final challenges = await getChallenges(levelId);
    if (challenges.isEmpty) return null;

    challenges.shuffle();
    return challenges.first;
  }

  /// Get challenges by difficulty score range
  Future<List<Challenge>> getChallengesByDifficultyRange(
      String levelId, int minScore, int maxScore) async {
    final challenges = await getChallenges(levelId);
    return challenges
        .where((challenge) =>
            challenge.difficultyScore >= minScore &&
            challenge.difficultyScore <= maxScore)
        .toList();
  }

  // ===== CHAPTERS =====

  /// Get all chapters
  Future<List<Chapter>> getChapters() async {
    if (_chaptersCache != null) {
      return _chaptersCache!;
    }

    _chaptersCache = await _dbService.getChapters();
    return _chaptersCache!;
  }

  /// Get a specific chapter
  Future<Chapter?> getChapter(String chapterId) async {
    final chapters = await getChapters();
    return chapters.firstWhere(
      (chapter) => chapter.id == chapterId,
      orElse: () => throw Exception('Chapter not found: $chapterId'),
    );
  }

  /// Get chapters by order index
  Future<List<Chapter>> getChaptersByOrder(int startIndex, int endIndex) async {
    final chapters = await getChapters();
    return chapters
        .where((chapter) =>
            chapter.orderIndex >= startIndex && chapter.orderIndex <= endIndex)
        .toList();
  }

  /// Get the next chapter after a given chapter
  Future<Chapter?> getNextChapter(String currentChapterId) async {
    final currentChapter = await getChapter(currentChapterId);
    if (currentChapter == null) return null;

    final chapters = await getChapters();
    final nextIndex = currentChapter.orderIndex + 1;

    return chapters.firstWhere(
      (chapter) => chapter.orderIndex == nextIndex,
      orElse: () => null,
    );
  }

  // ===== REALMS =====

  /// Get all realms
  Future<List<Realm>> getRealms() async {
    if (_realmsCache != null) {
      return _realmsCache!;
    }

    _realmsCache = await _dbService.getRealms();
    return _realmsCache!;
  }

  /// Get a specific realm
  Future<Realm?> getRealm(String realmId) async {
    final realms = await getRealms();
    return realms.firstWhere(
      (realm) => realm.id == realmId,
      orElse: () => throw Exception('Realm not found: $realmId'),
    );
  }

  // ===== ACHIEVEMENTS =====

  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    if (_achievementsCache != null) {
      return _achievementsCache!;
    }

    _achievementsCache = await _dbService.getAchievements();
    return _achievementsCache!;
  }

  /// Get a specific achievement
  Future<Achievement?> getAchievement(String achievementId) async {
    final achievements = await getAchievements();
    return achievements.firstWhere(
      (achievement) => achievement.id == achievementId,
      orElse: () => throw Exception('Achievement not found: $achievementId'),
    );
  }

  /// Get achievements by points range
  Future<List<Achievement>> getAchievementsByPointsRange(
      int minPoints, int maxPoints) async {
    final achievements = await getAchievements();
    return achievements
        .where((achievement) =>
            achievement.points >= minPoints && achievement.points <= maxPoints)
        .toList();
  }

  // ===== USER PROGRESS =====

  /// Get user progress for a game
  Future<List<UserProgress>> getUserProgress(
      String userId, String gameId) async {
    return await _dbService.getUserProgress(userId, gameId);
  }

  /// Save user progress
  Future<bool> saveUserProgress({
    required String userId,
    required String gameId,
    required String levelId,
    required int score,
    required bool completed,
    int? timeSeconds,
    int attempts = 1,
  }) async {
    final progress = UserProgress(
      id: _uuid.v4(),
      userId: userId,
      gameId: gameId,
      levelId: levelId,
      score: score,
      completed: completed,
      timeSeconds: timeSeconds,
      attempts: attempts,
      completedAt: completed ? DateTime.now() : null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );

    return await _dbService.saveUserProgress(progress);
  }

  /// Get user's highest score for a level
  Future<int> getUserHighestScore(String userId, String levelId) async {
    final progress = await _dbService.getUserProgress(userId, '');
    final levelProgress = progress.where((p) => p.levelId == levelId).toList();

    if (levelProgress.isEmpty) return 0;

    return levelProgress.map((p) => p.score).reduce((a, b) => a > b ? a : b);
  }

  /// Check if user has completed a level
  Future<bool> hasUserCompletedLevel(String userId, String levelId) async {
    final progress = await _dbService.getUserProgress(userId, '');
    return progress.any((p) => p.levelId == levelId && p.completed);
  }

  /// Get user's completion percentage for a game
  Future<double> getUserGameCompletionPercentage(
      String userId, String gameId) async {
    final levels = await getLevels(gameId);
    if (levels.isEmpty) return 0.0;

    final completedLevels = await Future.wait(
        levels.map((level) => hasUserCompletedLevel(userId, level.id)));

    final completedCount =
        completedLevels.where((completed) => completed).length;
    return (completedCount / levels.length) * 100;
  }

  // ===== UTILITY METHODS =====

  /// Check if a level is unlocked for a user
  Future<bool> isLevelUnlocked(
      String userId, String gameId, int levelNumber) async {
    if (levelNumber == 1) return true; // First level is always unlocked

    final level = await getLevel(gameId, levelNumber);
    if (level == null) return false;

    // Check if previous level is completed
    final previousLevel = await getLevel(gameId, levelNumber - 1);
    if (previousLevel == null) return false;

    return await hasUserCompletedLevel(userId, previousLevel.id);
  }

  /// Get recommended next level for user
  Future<Level?> getRecommendedNextLevel(String userId, String gameId) async {
    final levels = await getLevels(gameId);

    for (final level in levels) {
      if (!await hasUserCompletedLevel(userId, level.id)) {
        return level;
      }
    }

    return null; // All levels completed
  }

  /// Get user's total score for a game
  Future<int> getUserTotalScore(String userId, String gameId) async {
    final progress = await getUserProgress(userId, gameId);
    return progress.fold(0, (sum, p) => sum + p.score);
  }

  /// Get user's total play time for a game
  Future<int> getUserTotalPlayTime(String userId, String gameId) async {
    final progress = await getUserProgress(userId, gameId);
    return progress.fold(0, (sum, p) => sum + (p.timeSeconds ?? 0));
  }

  /// Close database connection
  Future<void> dispose() async {
    await _dbService.close();
    clearCache();
  }
}
