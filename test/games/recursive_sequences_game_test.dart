import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/games/recursive_sequences_game.dart';
import 'package:algebrini_edu_game/models/minigame.dart';

void main() {
  group('RecursiveSequencesGame', () {
    late RecursiveSequencesGame game;

    setUp(() {
      game = RecursiveSequencesGame();
    });

    test('initializes with correct metadata', () {
      expect(game.title, 'Recursive Sequences');
      expect(game.id, 'recursive-sequences');
    });

    test('starts with the first challenge', () {
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, '1, 1, 2, 3, 5, ?');
    });

    test('checkAnswer returns true for correct answer', () {
      // First challenge is Fibonacci: 1, 1, 2, 3, 5, ? -> answer is 8
      expect(game.checkAnswer('8'), isTrue);
    });

    test('checkAnswer returns false for incorrect answer', () {
      expect(game.checkAnswer('7'), isFalse);
    });

    test('next() moves to the second challenge', () {
      game.next();
      final GameChallenge challenge = game.getChallenge();
      // Second challenge is Arithmetic: 2, 4, 6, 8, 10, ? -> answer is 12
      expect(challenge.question, '2, 4, 6, 8, 10, ?');
      expect(game.checkAnswer('12'), isTrue);
    });
    
    test('next() moves to the third challenge', () {
      game.next(); // to second
      game.next(); // to third
      final GameChallenge challenge = game.getChallenge();
      // Third challenge is Geometric: 3, 6, 12, 24, 48, ? -> answer is 96
      expect(challenge.question, '3, 6, 12, 24, 48, ?');
      expect(game.checkAnswer('96'), isTrue);
    });

    test('next() loops back to the first challenge', () {
      game.next(); // 2
      game.next(); // 3
      game.next(); // 1
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, '1, 1, 2, 3, 5, ?');
      expect(game.checkAnswer('8'), isTrue);
    });
    
    test('getHint() returns the correct hint for the current challenge', () {
      expect(game.getHint(), 'Each number is the sum of the previous two.');
      game.next();
      expect(game.getHint(), 'Each number increases by a constant value.');
      game.next();
      expect(game.getHint(), 'Each number is multiplied by a constant value.');
    });

    test('reset() resets the game to the first challenge', () {
      game.next();
      game.next();
      expect(game.getChallenge().question, isNot('1, 1, 2, 3, 5, ?'));
      
      game.reset();
      expect(game.getChallenge().question, '1, 1, 2, 3, 5, ?');
      expect(game.checkAnswer('8'), isTrue);
    });
  });
} 