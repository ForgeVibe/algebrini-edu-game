import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:postgres/postgres.dart';
import '../models/database_models.dart';

class DatabaseService {
  static const String _baseUrl = 'http://localhost:3000/api'; // API base URL
  static const String _dbHost = 'localhost';
  static const int _dbPort = 5432;
  static const String _dbName = 'algebrini_dev';
  static const String _dbUser = 'algebrini_user';
  static const String _dbPassword = 'algebrini_dev_password';

  late PostgreSQLConnection _connection;
  bool _isConnected = false;

  // Singleton pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  /// Initialize database connection
  Future<void> initialize() async {
    try {
      _connection = PostgreSQLConnection(
        _dbHost,
        _dbPort,
        _dbName,
        username: _dbUser,
        password: _dbPassword,
      );
      
      await _connection.open();
      _isConnected = true;
      print('Database connected successfully');
    } catch (e) {
      print('Failed to connect to database: $e');
      _isConnected = false;
    }
  }

  /// Close database connection
  Future<void> close() async {
    if (_isConnected) {
      await _connection.close();
      _isConnected = false;
    }
  }

  /// Check if database is connected
  bool get isConnected => _isConnected;

  // ===== GAMES =====
  
  /// Get all games
  Future<List<Game>> getGames() async {
    if (!_isConnected) {
      return _getGamesFromApi();
    }

    try {
      final results = await _connection.query(
        'SELECT id, name, description, icon, difficulty_levels, created_at, updated_at, is_active FROM games WHERE is_active = true ORDER BY name'
      );
      
      return results.map((row) => Game(
        id: row[0] as String,
        name: row[1] as String,
        description: row[2] as String?,
        icon: row[3] as String?,
        difficultyLevels: row[4] as int,
        createdAt: row[5] as DateTime,
        updatedAt: row[6] as DateTime,
        isActive: row[7] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching games: $e');
      return [];
    }
  }

  /// Get game by ID
  Future<Game?> getGameById(String gameId) async {
    if (!_isConnected) {
      return _getGameFromApi(gameId);
    }

    try {
      final results = await _connection.query(
        'SELECT id, name, description, icon, difficulty_levels, created_at, updated_at, is_active FROM games WHERE id = @gameId AND is_active = true',
        substitutionValues: {'gameId': gameId}
      );
      
      if (results.isEmpty) return null;
      
      final row = results.first;
      return Game(
        id: row[0] as String,
        name: row[1] as String,
        description: row[2] as String?,
        icon: row[3] as String?,
        difficultyLevels: row[4] as int,
        createdAt: row[5] as DateTime,
        updatedAt: row[6] as DateTime,
        isActive: row[7] as bool,
      );
    } catch (e) {
      print('Error fetching game: $e');
      return null;
    }
  }

  // ===== LEVELS =====
  
  /// Get levels for a specific game
  Future<List<Level>> getLevelsByGameId(String gameId) async {
    if (!_isConnected) {
      return _getLevelsFromApi(gameId);
    }

    try {
      final results = await _connection.query(
        'SELECT id, game_id, level_number, difficulty, requirements, created_at, updated_at, is_active FROM levels WHERE game_id = @gameId AND is_active = true ORDER BY level_number',
        substitutionValues: {'gameId': gameId}
      );
      
      return results.map((row) => Level(
        id: row[0] as String,
        gameId: row[1] as String,
        levelNumber: row[2] as int,
        difficulty: DifficultyLevel.values.firstWhere(
          (e) => e.name == (row[3] as String),
          orElse: () => DifficultyLevel.easy,
        ),
        requirements: row[4] != null ? jsonDecode(row[4] as String) : null,
        createdAt: row[5] as DateTime,
        updatedAt: row[6] as DateTime,
        isActive: row[7] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching levels: $e');
      return [];
    }
  }

  // ===== CHALLENGES =====
  
  /// Get challenges for a specific level
  Future<List<Challenge>> getChallengesByLevelId(String levelId) async {
    if (!_isConnected) {
      return _getChallengesFromApi(levelId);
    }

    try {
      final results = await _connection.query(
        'SELECT id, level_id, question, answer, hint, explanation, metadata, difficulty_score, created_at, updated_at, is_active FROM challenges WHERE level_id = @levelId AND is_active = true ORDER BY difficulty_score',
        substitutionValues: {'levelId': levelId}
      );
      
      return results.map((row) => Challenge(
        id: row[0] as String,
        levelId: row[1] as String,
        question: row[2] as String,
        answer: row[3] as String,
        hint: row[4] as String?,
        explanation: row[5] as String?,
        metadata: row[6] != null ? jsonDecode(row[6] as String) : null,
        difficultyScore: row[7] as int,
        createdAt: row[8] as DateTime,
        updatedAt: row[9] as DateTime,
        isActive: row[10] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching challenges: $e');
      return [];
    }
  }

  // ===== CHAPTERS =====
  
  /// Get all chapters
  Future<List<Chapter>> getChapters() async {
    if (!_isConnected) {
      return _getChaptersFromApi();
    }

    try {
      final results = await _connection.query(
        'SELECT id, title, subtitle, description, requirements, realm_id, games, levels, story_cutscene_id, rewards, order_index, created_at, updated_at, is_active FROM chapters WHERE is_active = true ORDER BY order_index'
      );
      
      return results.map((row) => Chapter(
        id: row[0] as String,
        title: row[1] as String,
        subtitle: row[2] as String?,
        description: row[3] as String?,
        requirements: row[4] != null ? jsonDecode(row[4] as String) : null,
        realmId: row[5] as String?,
        games: List<String>.from(jsonDecode(row[6] as String)),
        levels: List<int>.from(jsonDecode(row[7] as String)),
        storyCutsceneId: row[8] as String?,
        rewards: row[9] != null ? jsonDecode(row[9] as String) : null,
        orderIndex: row[10] as int,
        createdAt: row[11] as DateTime,
        updatedAt: row[12] as DateTime,
        isActive: row[13] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching chapters: $e');
      return [];
    }
  }

  // ===== REALMS =====
  
  /// Get all realms
  Future<List<Realm>> getRealms() async {
    if (!_isConnected) {
      return _getRealmsFromApi();
    }

    try {
      final results = await _connection.query(
        'SELECT id, name, description, color, icon, background, created_at, updated_at, is_active FROM realms WHERE is_active = true ORDER BY name'
      );
      
      return results.map((row) => Realm(
        id: row[0] as String,
        name: row[1] as String,
        description: row[2] as String?,
        color: row[3] as String?,
        icon: row[4] as String?,
        background: row[5] as String?,
        createdAt: row[6] as DateTime,
        updatedAt: row[7] as DateTime,
        isActive: row[8] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching realms: $e');
      return [];
    }
  }

  // ===== ACHIEVEMENTS =====
  
  /// Get all achievements
  Future<List<Achievement>> getAchievements() async {
    if (!_isConnected) {
      return _getAchievementsFromApi();
    }

    try {
      final results = await _connection.query(
        'SELECT id, title, description, icon, color, requirements, points, created_at, updated_at, is_active FROM achievements WHERE is_active = true ORDER BY points DESC'
      );
      
      return results.map((row) => Achievement(
        id: row[0] as String,
        title: row[1] as String,
        description: row[2] as String?,
        icon: row[3] as String?,
        color: row[4] as String?,
        requirements: row[5] != null ? jsonDecode(row[5] as String) : null,
        points: row[6] as int,
        createdAt: row[7] as DateTime,
        updatedAt: row[8] as DateTime,
        isActive: row[9] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching achievements: $e');
      return [];
    }
  }

  // ===== USER PROGRESS =====
  
  /// Get user progress for a specific game
  Future<List<UserProgress>> getUserProgress(String userId, String gameId) async {
    if (!_isConnected) {
      return _getUserProgressFromApi(userId, gameId);
    }

    try {
      final results = await _connection.query(
        'SELECT id, user_id, game_id, level_id, score, completed, time_seconds, attempts, completed_at, created_at, updated_at, is_active FROM user_progress WHERE user_id = @userId AND game_id = @gameId AND is_active = true ORDER BY created_at DESC',
        substitutionValues: {'userId': userId, 'gameId': gameId}
      );
      
      return results.map((row) => UserProgress(
        id: row[0] as String,
        userId: row[1] as String,
        gameId: row[2] as String,
        levelId: row[3] as String,
        score: row[4] as int,
        completed: row[5] as bool,
        timeSeconds: row[6] as int?,
        attempts: row[7] as int,
        completedAt: row[8] as DateTime?,
        createdAt: row[9] as DateTime,
        updatedAt: row[10] as DateTime,
        isActive: row[11] as bool,
      )).toList();
    } catch (e) {
      print('Error fetching user progress: $e');
      return [];
    }
  }

  /// Save user progress
  Future<bool> saveUserProgress(UserProgress progress) async {
    if (!_isConnected) {
      return _saveUserProgressToApi(progress);
    }

    try {
      await _connection.query(
        '''
        INSERT INTO user_progress (id, user_id, game_id, level_id, score, completed, time_seconds, attempts, completed_at, created_at, updated_at, is_active)
        VALUES (@id, @userId, @gameId, @levelId, @score, @completed, @timeSeconds, @attempts, @completedAt, @createdAt, @updatedAt, @isActive)
        ON CONFLICT (user_id, level_id) DO UPDATE SET
          score = EXCLUDED.score,
          completed = EXCLUDED.completed,
          time_seconds = EXCLUDED.time_seconds,
          attempts = EXCLUDED.attempts,
          completed_at = EXCLUDED.completed_at,
          updated_at = EXCLUDED.updated_at
        ''',
        substitutionValues: {
          'id': progress.id,
          'userId': progress.userId,
          'gameId': progress.gameId,
          'levelId': progress.levelId,
          'score': progress.score,
          'completed': progress.completed,
          'timeSeconds': progress.timeSeconds,
          'attempts': progress.attempts,
          'completedAt': progress.completedAt,
          'createdAt': progress.createdAt,
          'updatedAt': progress.updatedAt,
          'isActive': progress.isActive,
        }
      );
      return true;
    } catch (e) {
      print('Error saving user progress: $e');
      return false;
    }
  }

  // ===== API FALLBACK METHODS =====
  
  Future<List<Game>> _getGamesFromApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/games'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Game.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching games: $e');
    }
    return [];
  }

  Future<Game?> _getGameFromApi(String gameId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/games/$gameId'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Game.fromJson(json);
      }
    } catch (e) {
      print('API error fetching game: $e');
    }
    return null;
  }

  Future<List<Level>> _getLevelsFromApi(String gameId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/games/$gameId/levels'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Level.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching levels: $e');
    }
    return [];
  }

  Future<List<Challenge>> _getChallengesFromApi(String levelId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/levels/$levelId/challenges'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Challenge.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching challenges: $e');
    }
    return [];
  }

  Future<List<Chapter>> _getChaptersFromApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/chapters'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Chapter.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching chapters: $e');
    }
    return [];
  }

  Future<List<Realm>> _getRealmsFromApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/realms'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Realm.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching realms: $e');
    }
    return [];
  }

  Future<List<Achievement>> _getAchievementsFromApi() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/achievements'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Achievement.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching achievements: $e');
    }
    return [];
  }

  Future<List<UserProgress>> _getUserProgressFromApi(String userId, String gameId) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users/$userId/progress?gameId=$gameId'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => UserProgress.fromJson(json)).toList();
      }
    } catch (e) {
      print('API error fetching user progress: $e');
    }
    return [];
  }

  Future<bool> _saveUserProgressToApi(UserProgress progress) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/${progress.userId}/progress'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(progress.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('API error saving user progress: $e');
      return false;
    }
  }
} 