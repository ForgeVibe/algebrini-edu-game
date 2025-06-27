import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';

class RecursiveSequencesGame implements MiniGame {
  int _currentIndex = 0;
  late List<int> _currentSequence;
  late int _answer;
  late String _hint;

  final List<Map<String, dynamic>> _allSequences = [
    {
      'sequence': [1, 1, 2, 3, 5],
      'type': 'Fibonacci',
      'hint': 'Each number is the sum of the previous two.',
    },
    {
      'sequence': [2, 4, 6, 8, 10],
      'type': 'Arithmetic',
      'hint': 'Each number increases by a constant value.',
    },
    {
      'sequence': [3, 6, 12, 24, 48],
      'type': 'Geometric',
      'hint': 'Each number is multiplied by a constant value.',
    },
  ];

  RecursiveSequencesGame() {
    _loadChallenge();
  }

  void _loadChallenge() {
    final challengeData = _allSequences[_currentIndex % _allSequences.length];
    _currentSequence = List<int>.from(challengeData['sequence']);
    _hint = challengeData['hint'];

    if (challengeData['type'] == 'Fibonacci') {
      _answer = _currentSequence[_currentSequence.length - 2] + _currentSequence[_currentSequence.length - 1];
    } else if (challengeData['type'] == 'Arithmetic') {
      _answer = _currentSequence.last + (_currentSequence[1] - _currentSequence[0]);
    } else { // Geometric
      _answer = _currentSequence.last * (_currentSequence[1] ~/ _currentSequence[0]);
    }
  }

  @override
  String get title => 'Recursive Sequences';

  @override
  String get id => 'recursive-sequences';

  @override
  IconData get icon => Icons.trending_up;

  @override
  String get description => 'Find the next number in the sequence.';

  @override
  GameChallenge getChallenge() {
    final question = '${_currentSequence.join(', ')}, ?';
    return GameChallenge(question: question, data: {'sequence': _currentSequence});
  }

  @override
  bool checkAnswer(String answer) {
    return answer.trim() == _answer.toString();
  }

  @override
  void next() {
    _currentIndex++;
    _loadChallenge();
  }

  @override
  String getHint() {
    return _hint;
  }

  @override
  void reset() {
    _currentIndex = 0;
    _loadChallenge();
  }
} 