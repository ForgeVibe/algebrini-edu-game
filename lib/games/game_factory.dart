import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'game_loader.dart'; // This ensures all games are loaded and registered

/// Factory for creating game instances using the GameRegistry
/// 
/// This factory uses the plugin-based GameRegistry to dynamically create
/// game instances. New games can be added by creating plugins without
/// modifying this factory.
class GameFactory {
  static final GameRegistry _registry = GameRegistry();

  /// Create a game instance by ID
  /// 
  /// Uses the GameRegistry to find and create the appropriate game.
  /// Supports both hardcoded and database-driven games.
  static MiniGame createGame(String gameId) {
    // Ensure all games are loaded
    GameLoader.loadAllGames();
    
    final game = _registry.getGameById(gameId);
    if (game == null) {
      throw ArgumentError('Unknown game ID: $gameId');
    }
    
    return game;
  }

  /// Create a game instance with database support
  /// 
  /// Initializes the registry with database support and creates a game
  /// that can use database-driven content.
  static Future<MiniGame> createGameWithDatabase(
      String gameId, GameDataService gameDataService) async {
    // Ensure all games are loaded
    GameLoader.loadAllGames();
    
    // Initialize registry with database
    _registry.initializeWithDatabase(gameDataService);
    
    final game = _registry.getGameById(gameId);
    if (game == null) {
      throw ArgumentError('Unknown game ID: $gameId');
    }
    
    return game;
  }

  /// Get all available game IDs
  /// 
  /// Returns the IDs of all registered games.
  static List<String> getAvailableGames() {
    GameLoader.loadAllGames();
    return _registry.getAvailableGameIds();
  }

  /// Get game title by ID
  /// 
  /// Returns the title of a game from its metadata.
  static String getGameTitle(String gameId) {
    GameLoader.loadAllGames();
    final metadata = _registry.getGameMetadata(gameId);
    return metadata?.title ?? 'Unknown Game';
  }

  /// Get game description by ID
  /// 
  /// Returns the description of a game from its metadata.
  static String getGameDescription(String gameId) {
    GameLoader.loadAllGames();
    final metadata = _registry.getGameMetadata(gameId);
    return metadata?.description ?? 'Unknown game description';
  }

  /// Get game icon by ID
  /// 
  /// Returns the icon of a game from its metadata.
  static IconData? getGameIcon(String gameId) {
    GameLoader.loadAllGames();
    final metadata = _registry.getGameMetadata(gameId);
    return metadata?.icon;
  }

  /// Get all game metadata
  /// 
  /// Returns metadata for all registered games.
  static List<GameMetadata> getAllGameMetadata() {
    GameLoader.loadAllGames();
    return _registry.getAllGameMetadata();
  }

  /// Check if a game is registered
  /// 
  /// Returns true if the game ID is registered with the registry.
  static bool isGameRegistered(String gameId) {
    GameLoader.loadAllGames();
    return _registry.isGameRegistered(gameId);
  }

  /// Get all available games as MiniGame instances
  /// 
  /// Returns all registered games as MiniGame instances.
  static List<MiniGame> getAllGames() {
    GameLoader.loadAllGames();
    return _registry.getGames();
  }

  /// Check if database is being used
  /// 
  /// Returns true if the registry is configured to use database-driven games.
  static bool get useDatabase => _registry.useDatabase;

  /// Get the game data service if available
  /// 
  /// Returns the GameDataService instance if the registry is initialized with database support.
  static GameDataService? get gameDataService => _registry.gameDataService;

  /// Reload games
  /// 
  /// Reloads all games from the registry (useful for hot reload during development).
  static void reloadGames() {
    _registry.reloadGames();
  }
}
