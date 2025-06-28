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
      expect(challenge.question, contains('2, 4, 6, 8, 10'));
    });

    test('checkAnswer returns true for correct answer', () {
      // First challenge is 2,4,6,8,10 with answer 12
      expect(game.checkAnswer('12'), isTrue);
    });

    test('checkAnswer returns false for incorrect answer', () {
      expect(game.checkAnswer('11'), isFalse);
    });

    test('next() moves to the second challenge', () {
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, contains('1, 3, 5, 7, 9'));
    });

    test('next() moves to the third challenge', () {
      game.next();
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, contains('5, 10, 15, 20, 25'));
    });

    test('next() loops back to the first challenge', () {
      game.next();
      game.next();
      game.next();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, contains('2, 4, 6, 8, 10'));
    });

    test('getHint() returns the correct hint for the current challenge', () {
      expect(game.getHint(), 'Each number increases by 2.');
    });

    test('reset() resets the game to the first challenge', () {
      game.next();
      game.reset();
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, contains('2, 4, 6, 8, 10'));
    });

    test('setLevel() changes the current level', () {
      game.setLevel(2);
      expect(game.currentLevel, 2);
      final GameChallenge challenge = game.getChallenge();
      expect(challenge.question, contains('2, 4, 8, 16, 32'));
    });

    test('getAvailableLevels() returns all levels', () {
      final levels = RecursiveSequencesGame.getAvailableLevels();
      expect(levels, [1, 2, 3, 4, 5]);
    });

    test('getLevelInfo() returns correct information', () {
      final info = RecursiveSequencesGame.getLevelInfo(1);
      expect(info['level'], 1);
      expect(info['difficulty'], 'Easy');
      expect(info['sequenceCount'], 3);
    });

    test('getLevelDescription() returns correct description', () {
      final description = RecursiveSequencesGame.getLevelDescription(1);
      expect(description, contains('arithmetic sequences'));
    });
  });
} 