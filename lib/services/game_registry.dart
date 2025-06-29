import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/database_models.dart';

/// A service that provides a list of all available mini-games in the app.
///
/// This is a true plugin system that can dynamically discover and load games
/// without hardcoded imports. Games register themselves with the registry.
class GameRegistry {
  static final GameRegistry _instance = GameRegistry._internal();

  factory GameRegistry() {
    return _instance;
  }

  GameRegistry._internal();

  GameDataService? _gameDataService;
  List<MiniGame>? _databaseGames;
  
  // Plugin system: Games register themselves here
  static final Map<String, GamePlugin> _gamePlugins = {};
  static final Map<String, GameMetadata> _gameMetadata = {};

  /// Register a game plugin with the registry
  /// This allows games to register themselves without modifying the registry
  static void registerGame(String gameId, GamePlugin plugin, GameMetadata metadata) {
    _gamePlugins[gameId] = plugin;
    _gameMetadata[gameId] = metadata;
    print('Game registered: $gameId - ${metadata.title}');
  }

  /// Initialize the registry with database support
  void initializeWithDatabase(GameDataService gameDataService) {
    _gameDataService = gameDataService;
    _loadDatabaseGames();
  }

  /// Load games from database using the plugin system
  void _loadDatabaseGames() {
    if (_gameDataService == null) return;
    
    _databaseGames = [];
    
    // Use registered plugins to create database-driven games
    for (String gameId in _gamePlugins.keys) {
      try {
        final plugin = _gamePlugins[gameId]!;
        final game = plugin.createWithDatabase(_gameDataService!);
        if (game != null) {
          _databaseGames!.add(game);
        }
      } catch (e) {
        print('Error loading game $gameId from database: $e');
      }
    }
  }

  /// Returns a list of all available mini-games.
  /// If database is available, returns database-driven games.
  /// Otherwise, returns hardcoded games using plugins.
  List<MiniGame> getGames() {
    if (_databaseGames != null && _databaseGames!.isNotEmpty) {
      return List.unmodifiable(_databaseGames!);
    }

    // Fallback to hardcoded games using plugins
    final games = <MiniGame>[];
    for (String gameId in _gamePlugins.keys) {
      try {
        final plugin = _gamePlugins[gameId]!;
        final game = plugin.create();
        games.add(game);
      } catch (e) {
        print('Error creating game $gameId: $e');
      }
    }
    
    return List.unmodifiable(games);
  }

  /// Finds a game by its unique ID.
  MiniGame? getGameById(String id) {
    final games = getGames();
    try {
      return games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get metadata for a game
  GameMetadata? getGameMetadata(String gameId) {
    return _gameMetadata[gameId];
  }

  /// Get all registered game metadata
  List<GameMetadata> getAllGameMetadata() {
    return _gameMetadata.values.toList();
  }

  /// Get available game IDs
  List<String> getAvailableGameIds() {
    return _gamePlugins.keys.toList();
  }

  /// Check if database is being used
  bool get useDatabase => _databaseGames != null && _databaseGames!.isNotEmpty;

  /// Get the game data service if available
  GameDataService? get gameDataService => _gameDataService;

  /// Reload games (useful for hot reload during development)
  void reloadGames() {
    if (_gameDataService != null) {
      _loadDatabaseGames();
    }
  }

  /// Check if a game is registered
  bool isGameRegistered(String gameId) {
    return _gamePlugins.containsKey(gameId);
  }

  /// Get plugin for a game
  GamePlugin? getGamePlugin(String gameId) {
    return _gamePlugins[gameId];
  }
}

/// Plugin interface for games to register themselves
abstract class GamePlugin {
  /// Create a game instance with hardcoded data
  MiniGame create();
  
  /// Create a game instance with database support
  MiniGame? createWithDatabase(GameDataService gameDataService);
}

/// Metadata for a game
class GameMetadata {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int difficultyLevels;
  final List<String> tags;
  final String version;

  GameMetadata({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.difficultyLevels = 5,
    this.tags = const [],
    this.version = '1.0.0',
  });
}
