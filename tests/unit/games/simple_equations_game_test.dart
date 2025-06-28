import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/games/simple_equations_game.dart';
import 'package:algebrini_edu_game/models/minigame.dart';

void main() {
  group('SimpleEquationsGame', () {
    late SimpleEquationsGame game;

    setUp(() {
      game = SimpleEquationsGame();
    });

    test('initializes with correct metadata', () {
      expect(game.title, 'Simple Equations');
      expect(game.id, 'simple-equations');
    });

    test('starts with the first challenge', () {
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'Solve: x + 5 = 12');
    });

    test('checkAnswer returns true for correct answer', () {
      // First challenge is x + 5 = 12, answer is 7
      expect(game.checkAnswer('7'), isTrue);
    });

    test('checkAnswer returns false for incorrect answer', () {
      expect(game.checkAnswer('8'), isFalse);
    });

    test('next() moves to the next challenge', () {
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'Solve: x - 3 = 8');
    });

    test('next() loops back to the first challenge after the last one', () {
      game.next();
      game.next();
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'Solve: x + 5 = 12');
    });

    test('getHint() returns a relevant hint', () {
      expect(game.getHint(), 'Subtract 5 from both sides.');
    });

    test('reset() resets the game to the first challenge', () {
      game.next();
      game.reset();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'Solve: x + 5 = 12');
    });

    test('setLevel() changes the current level', () {
      game.setLevel(2);
      expect(game.currentLevel, 2);
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'Solve: 2x = 10');
    });

    test('getAvailableLevels() returns all levels', () {
      final levels = SimpleEquationsGame.getAvailableLevels();
      expect(levels, [1, 2, 3, 4, 5]);
    });

    test('getLevelInfo() returns correct information', () {
      final info = SimpleEquationsGame.getLevelInfo(1);
      expect(info['level'], 1);
      expect(info['difficulty'], 'Easy');
      expect(info['equationCount'], 3);
    });

    test('getLevelDescription() returns correct description', () {
      final description = SimpleEquationsGame.getLevelDescription(1);
      expect(description, 'Simple addition and subtraction equations.');
    });

    test('getSolutionSteps() returns solution steps', () {
      final steps = game.getSolutionSteps();
      expect(steps, isNotEmpty);
      expect(steps.first, contains('x + 5 - 5'));
    });
  });
} 