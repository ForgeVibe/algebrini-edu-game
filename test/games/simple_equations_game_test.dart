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
      expect(challenge.question, 'x + 3 = 7');
    });

    test('checkAnswer returns true for correct answer', () {
      // First challenge: x + 3 = 7 -> answer is 4
      expect(game.checkAnswer('4'), isTrue);
    });

    test('checkAnswer returns false for incorrect answer', () {
      expect(game.checkAnswer('10'), isFalse);
    });

    test('next() moves to the next challenge', () {
      game.next();
      final GameChallenge challenge = game.getChallenge();
      // Second challenge: 2x = 10 -> answer is 5
      expect(challenge.question, '2x = 10');
      expect(game.checkAnswer('5'), isTrue);
    });
    
    test('next() loops back to the first challenge after the last one', () {
      // There are 5 equations in the list
      for (int i = 0; i < 5; i++) {
        game.next();
      }
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'x + 3 = 7');
      expect(game.checkAnswer('4'), isTrue);
    });
    
    test('getHint() returns a relevant hint', () {
      // x + 3 = 7
      expect(game.getHint(), contains('subtract'));
      game.next(); // 2x = 10
      // This is a bit tricky, the regex is simple. It will match the 'x'
      expect(game.getHint(), contains('divide'));
      game.next(); // x - 5 = 2
      expect(game.getHint(), contains('add'));
    });

    test('reset() resets the game to the first challenge', () {
      game.next();
      game.next();
      expect(game.getChallenge().question, isNot('x + 3 = 7'));
      
      game.reset();
      expect(game.getChallenge().question, 'x + 3 = 7');
      expect(game.checkAnswer('4'), isTrue);
    });
  });
} 