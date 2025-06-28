import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/games/recursive_sequences_game.dart';
import 'package:algebrini_edu_game/games/simple_equations_game.dart';
import 'package:algebrini_edu_game/games/factorization_game.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';

/// A service that provides a list of all available mini-games in the app.
///
/// In a more advanced implementation, this could use reflection or another
/// mechanism for automatic discovery. For now, games are registered manually.
class GameRegistry {
  static final GameRegistry _instance = GameRegistry._internal();

  factory GameRegistry() {
    return _instance;
  }

  GameRegistry._internal();

  GameDataService? _gameDataService;
  List<MiniGame>? _databaseGames;

  /// Initialize the registry with database support
  void initializeWithDatabase(GameDataService gameDataService) {
    _gameDataService = gameDataService;
    _databaseGames = [
      RecursiveSequencesGame.withDatabase(gameDataService),
      SimpleEquationsGame.withDatabase(gameDataService),
      FactorizationGame.withDatabase(gameDataService),
    ];
  }

  /// Returns a list of all available mini-games.
  /// If database is available, returns database-driven games.
  /// Otherwise, returns hardcoded games.
  List<MiniGame> getGames() {
    if (_databaseGames != null) {
      return List.unmodifiable(_databaseGames!);
    }

    // Fallback to hardcoded games
    return List.unmodifiable([
      RecursiveSequencesGame(),
      SimpleEquationsGame(),
      FactorizationGame(),
    ]);
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

  /// Check if database is being used
  bool get useDatabase => _databaseGames != null;

  /// Get the game data service if available
  GameDataService? get gameDataService => _gameDataService;
}
