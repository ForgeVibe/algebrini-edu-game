import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';

class SimpleEquationsGame implements MiniGame {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> _equations = [
    {'question': 'x + 3 = 7', 'answer': 4},
    {'question': '2x = 10', 'answer': 5},
    {'question': 'x - 5 = 2', 'answer': 7},
    {'question': '3x = 9', 'answer': 3},
    {'question': 'x / 2 = 6', 'answer': 12},
  ];

  @override
  String get title => 'Simple Equations';

  @override
  String get id => 'simple-equations';

  @override
  IconData get icon => Icons.calculate;

  @override
  String get description => 'Solve for x in the equation.';

  @override
  GameChallenge getChallenge() {
    final equation = _equations[_currentIndex % _equations.length];
    return GameChallenge(question: equation['question']);
  }

  @override
  bool checkAnswer(String answer) {
    final equation = _equations[_currentIndex % _equations.length];
    return answer.trim() == equation['answer'].toString();
  }

  @override
  void next() {
    _currentIndex++;
  }

  @override
  String getHint() {
    // Basic hints for different types of equations
    final question = _equations[_currentIndex % _equations.length]['question'];
    if (question.contains('+')) {
      return 'To solve for x, subtract the number on the left from the number on the right.';
    } else if (question.contains('-')) {
      return 'To solve for x, add the number on the left to the number on the right.';
    } else if (question.contains('*') || question.contains('x') && !question.contains('+') && !question.contains('-')) {
      return 'To solve for x, divide the number on the right by the number next to x.';
    } else if (question.contains('/')) {
      return 'To solve for x, multiply the number on the right by the number on the bottom.';
    }
    return 'Isolate x on one side of the equation.';
  }

  @override
  void reset() {
    _currentIndex = 0;
  }
} 