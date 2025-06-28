import 'package:flutter_test/flutter_test.dart';
import 'package:algebrini_edu_game/games/factorization_game.dart';
import 'package:algebrini_edu_game/models/minigame.dart';

void main() {
  group('FactorizationGame', () {
    late FactorizationGame game;

    setUp(() {
      game = FactorizationGame();
    });

    test('initializes with correct metadata', () {
      expect(game.title, 'Factorization Fun');
      expect(game.id, 'factorization-fun');
    });

    test('starts with the first challenge', () {
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'What are all the factors of 6?');
    });

    test('checkAnswer returns true for correct answer', () {
      // Factors of 6: 1,2,3,6
      expect(game.checkAnswer('1,2,3,6'), isTrue);
    });

    test('checkAnswer returns false for incorrect answer', () {
      expect(game.checkAnswer('1,2,3'), isFalse); // Missing 6
      expect(game.checkAnswer('1,2,3,6,8'), isFalse); // Extra 8
    });

    test('next() moves to the next challenge', () {
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'What are all the factors of 8?');
    });

    test('reset() resets the game to the first challenge', () {
      game.next();
      game.reset();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'What are all the factors of 6?');
    });

    test('getHint() returns a helpful hint', () {
      expect(game.getHint(), 'A factor is a number that divides evenly into another number.');
    });

    test('setLevel() changes the current level', () {
      game.setLevel(2);
      expect(game.currentLevel, 2);
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, 'What are all the factors of 12?');
    });

    test('getAvailableLevels() returns all levels', () {
      final levels = FactorizationGame.getAvailableLevels();
      expect(levels, [1, 2, 3, 4, 5]);
    });

    test('getLevelInfo() returns correct information', () {
      final info = FactorizationGame.getLevelInfo(1);
      expect(info['level'], 1);
      expect(info['difficulty'], 'Easy');
      expect(info['numberCount'], 3);
    });

    test('getLevelDescription() returns correct description', () {
      final description = FactorizationGame.getLevelDescription(1);
      expect(description, 'Small numbers with simple factorization patterns.');
    });

    test('getCorrectFactors() returns the correct factors', () {
      final factors = game.getCorrectFactors();
      expect(factors, [1, 2, 3, 6]);
    });

    test('isPrime() correctly identifies prime numbers', () {
      expect(FactorizationGame.isPrime(2), isTrue);
      expect(FactorizationGame.isPrime(3), isTrue);
      expect(FactorizationGame.isPrime(4), isFalse);
      expect(FactorizationGame.isPrime(17), isTrue);
    });

    test('getFactors() returns all factors of a number', () {
      final factors = FactorizationGame.getFactors(12);
      expect(factors, [1, 2, 3, 4, 6, 12]);
    });
  });
} 