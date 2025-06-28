import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/games/recursive_sequences_game.dart';
import 'package:algebrini_edu_game/games/simple_equations_game.dart';
import 'package:algebrini_edu_game/games/factorization_game.dart';

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

  final List<MiniGame> _games = [
    RecursiveSequencesGame(),
    SimpleEquationsGame(),
    FactorizationGame(),
    // To add a new game, simply instantiate it and add it to this list.
  ];

  /// Returns a list of all available mini-games.
  List<MiniGame> getGames() {
    return List.unmodifiable(_games);
  }

  /// Finds a game by its unique ID.
  MiniGame? getGameById(String id) {
    try {
      return _games.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }
} 