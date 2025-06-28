import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/level_progression_service.dart';

class FactorizationGame implements MiniGame {
  int _currentIndex = 0;
  int _currentLevel = 1;
  late int _currentNumber;
  late List<int> _correctFactors;
  late String _hint;
  late String _factorizationType;

  // Level-specific numbers with increasing difficulty
  static const Map<int, List<Map<String, dynamic>>> _levelNumbers = {
    1: [ // Easy - Small numbers with few factors
      {
        'number': 6,
        'type': 'Small Composite',
        'hint': 'A factor is a number that divides evenly into another number.',
        'factors': [1, 2, 3, 6],
      },
      {
        'number': 8,
        'type': 'Power of 2',
        'hint': 'Think about what numbers divide 8 evenly.',
        'factors': [1, 2, 4, 8],
      },
      {
        'number': 10,
        'type': 'Small Composite',
        'hint': 'What numbers can you multiply to get 10?',
        'factors': [1, 2, 5, 10],
      },
    ],
    2: [ // Medium - Larger numbers with more factors
      {
        'number': 12,
        'type': 'Multiple Factors',
        'hint': '12 has more factors than smaller numbers.',
        'factors': [1, 2, 3, 4, 6, 12],
      },
      {
        'number': 15,
        'type': 'Product of Primes',
        'hint': '15 is 3 × 5, so its factors include 1, 3, 5, and 15.',
        'factors': [1, 3, 5, 15],
      },
      {
        'number': 16,
        'type': 'Power of 2',
        'hint': '16 is 2⁴, so its factors are powers of 2.',
        'factors': [1, 2, 4, 8, 16],
      },
    ],
    3: [ // Hard - Prime numbers and larger composites
      {
        'number': 17,
        'type': 'Prime',
        'hint': '17 is a prime number - it only has two factors.',
        'factors': [1, 17],
      },
      {
        'number': 21,
        'type': 'Product of Primes',
        'hint': '21 is 3 × 7, so its factors are 1, 3, 7, and 21.',
        'factors': [1, 3, 7, 21],
      },
      {
        'number': 25,
        'type': 'Perfect Square',
        'hint': '25 is 5², so its factors are 1, 5, and 25.',
        'factors': [1, 5, 25],
      },
    ],
    4: [ // Expert - Larger numbers with complex factorization
      {
        'number': 28,
        'type': 'Multiple Factors',
        'hint': '28 has many factors. Think about its prime factorization.',
        'factors': [1, 2, 4, 7, 14, 28],
      },
      {
        'number': 31,
        'type': 'Prime',
        'hint': '31 is a prime number.',
        'factors': [1, 31],
      },
      {
        'number': 36,
        'type': 'Perfect Square',
        'hint': '36 is 6², so it has many factors.',
        'factors': [1, 2, 3, 4, 6, 9, 12, 18, 36],
      },
    ],
    5: [ // Master - Complex numbers and large primes
      {
        'number': 49,
        'type': 'Perfect Square',
        'hint': '49 is 7².',
        'factors': [1, 7, 49],
      },
      {
        'number': 64,
        'type': 'Power of 2',
        'hint': '64 is 2⁶, so it has many factors.',
        'factors': [1, 2, 4, 8, 16, 32, 64],
      },
      {
        'number': 97,
        'type': 'Prime',
        'hint': '97 is a prime number.',
        'factors': [1, 97],
      },
    ],
  };

  FactorizationGame() {
    _loadChallenge();
  }

  void _loadChallenge() {
    final levelNumbers = _levelNumbers[_currentLevel] ?? _levelNumbers[1]!;
    final challengeData = levelNumbers[_currentIndex % levelNumbers.length];
    _currentNumber = challengeData['number'];
    _correctFactors = List<int>.from(challengeData['factors']);
    _hint = challengeData['hint'];
    _factorizationType = challengeData['type'];
  }

  @override
  String get title => 'Factorization Fun';

  @override
  String get id => 'factorization-fun';

  @override
  IconData get icon => Icons.filter_9_plus;

  @override
  String get description => 'Enter all factors of the given number, separated by commas.';

  @override
  GameChallenge getChallenge() {
    return GameChallenge(
      question: 'What are all the factors of $_currentNumber?', 
      data: {
        'number': _currentNumber,
        'level': _currentLevel,
        'type': _factorizationType,
      }
    );
  }

  @override
  bool checkAnswer(String answer) {
    // Parse the answer and check if it contains all and only the correct factors
    final answerParts = answer.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
    final answerFactors = answerParts.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
    
    // Check if all correct factors are present and no extra factors
    if (answerFactors.length != _correctFactors.length) return false;
    
    for (final factor in _correctFactors) {
      if (!answerFactors.contains(factor)) return false;
    }
    
    return true;
  }

  @override
  String getHint() {
    return _hint;
  }

  @override
  void next() {
    _currentIndex++;
    _loadChallenge();
  }

  @override
  void reset() {
    _currentIndex = 0;
    _currentLevel = 1;
    _loadChallenge();
  }

  // Level management methods
  void setLevel(int level) {
    _currentLevel = level;
    _currentIndex = 0;
    _loadChallenge();
  }

  int get currentLevel => _currentLevel;

  // Get available levels for this game
  static List<int> getAvailableLevels() {
    return _levelNumbers.keys.toList();
  }

  // Get level information
  static Map<String, dynamic> getLevelInfo(int level) {
    final numbers = _levelNumbers[level];
    if (numbers == null) return {};
    
    return {
      'level': level,
      'difficulty': _getDifficultyName(level),
      'numberCount': numbers.length,
      'types': numbers.map((n) => n['type']).toSet().toList(),
    };
  }

  static String _getDifficultyName(int level) {
    switch (level) {
      case 1: return 'Easy';
      case 2: return 'Medium';
      case 3: return 'Hard';
      case 4: return 'Expert';
      case 5: return 'Master';
      default: return 'Unknown';
    }
  }

  // Get level description
  static String getLevelDescription(int level) {
    switch (level) {
      case 1: return 'Small numbers with simple factorization patterns.';
      case 2: return 'Larger numbers with more factors to find.';
      case 3: return 'Prime numbers and perfect squares.';
      case 4: return 'Complex numbers with multiple factors.';
      case 5: return 'Large numbers including primes and powers.';
      default: return 'Unknown level.';
    }
  }

  // Get the correct factors for the current challenge
  List<int> getCorrectFactors() {
    return List.from(_correctFactors);
  }

  // Check if a number is prime
  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;
    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  // Get all factors of a number (utility method)
  static List<int> getFactors(int n) {
    final factors = <int>[];
    for (int i = 1; i <= n; i++) {
      if (n % i == 0) {
        factors.add(i);
      }
    }
    return factors;
  }
} 