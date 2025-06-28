import 'recursive_sequences_game.dart';
import 'simple_equations_game.dart';
import 'factorization_game.dart';
import 'base_game.dart';

class GameFactory {
  static BaseGame createGame(String gameId) {
    switch (gameId) {
      case 'recursive-sequences':
        return RecursiveSequencesGame();
      case 'simple-equations':
        return SimpleEquationsGame();
      case 'factorization-fun':
        return FactorizationGame();
      default:
        throw ArgumentError('Unknown game ID: $gameId');
    }
  }

  static List<String> getAvailableGames() {
    return [
      'recursive-sequences',
      'simple-equations',
      'factorization-fun',
    ];
  }

  static String getGameTitle(String gameId) {
    switch (gameId) {
      case 'recursive-sequences':
        return 'Recursive Sequences';
      case 'simple-equations':
        return 'Simple Equations';
      case 'factorization-fun':
        return 'Factorization Fun';
      default:
        return 'Unknown Game';
    }
  }

  static String getGameDescription(String gameId) {
    switch (gameId) {
      case 'recursive-sequences':
        return 'Discover patterns in number sequences';
      case 'simple-equations':
        return 'Solve equations with variables';
      case 'factorization-fun':
        return 'Break numbers into their factors';
      default:
        return 'Unknown game description';
    }
  }
}
