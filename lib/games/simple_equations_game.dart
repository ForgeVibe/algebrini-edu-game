import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/level_progression_service.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/database_models.dart';

class SimpleEquationsGame implements MiniGame {
  int _currentIndex = 0;
  int _currentLevel = 1;
  late String _currentEquation;
  late int _answer;
  late String _hint;
  late String _equationType;

  // Database support
  GameDataService? _gameDataService;
  String? _currentLevelId;
  List<Challenge>? _currentChallenges;
  bool _useDatabase = false;

  // Level-specific equations with increasing difficulty
  static const Map<int, List<Map<String, dynamic>>> _levelEquations = {
    1: [
      // Easy - Simple addition/subtraction
      {
        'equation': 'x + 5 = 12',
        'type': 'Addition',
        'hint': 'Subtract 5 from both sides.',
        'answer': 7,
        'steps': ['x + 5 - 5 = 12 - 5', 'x = 7'],
      },
      {
        'equation': 'x - 3 = 8',
        'type': 'Subtraction',
        'hint': 'Add 3 to both sides.',
        'answer': 11,
        'steps': ['x - 3 + 3 = 8 + 3', 'x = 11'],
      },
      {
        'equation': 'x + 7 = 15',
        'type': 'Addition',
        'hint': 'Subtract 7 from both sides.',
        'answer': 8,
        'steps': ['x + 7 - 7 = 15 - 7', 'x = 8'],
      },
    ],
    2: [
      // Medium - Multiplication/division
      {
        'equation': '2x = 10',
        'type': 'Multiplication',
        'hint': 'Divide both sides by 2.',
        'answer': 5,
        'steps': ['2x ÷ 2 = 10 ÷ 2', 'x = 5'],
      },
      {
        'equation': 'x ÷ 3 = 4',
        'type': 'Division',
        'hint': 'Multiply both sides by 3.',
        'answer': 12,
        'steps': ['x ÷ 3 × 3 = 4 × 3', 'x = 12'],
      },
      {
        'equation': '3x = 18',
        'type': 'Multiplication',
        'hint': 'Divide both sides by 3.',
        'answer': 6,
        'steps': ['3x ÷ 3 = 18 ÷ 3', 'x = 6'],
      },
    ],
    3: [
      // Hard - Two-step equations
      {
        'equation': '2x + 3 = 11',
        'type': 'Two-Step',
        'hint': 'First subtract 3, then divide by 2.',
        'answer': 4,
        'steps': ['2x + 3 - 3 = 11 - 3', '2x = 8', '2x ÷ 2 = 8 ÷ 2', 'x = 4'],
      },
      {
        'equation': '3x - 5 = 10',
        'type': 'Two-Step',
        'hint': 'First add 5, then divide by 3.',
        'answer': 5,
        'steps': ['3x - 5 + 5 = 10 + 5', '3x = 15', '3x ÷ 3 = 15 ÷ 3', 'x = 5'],
      },
      {
        'equation': 'x ÷ 2 + 4 = 9',
        'type': 'Two-Step',
        'hint': 'First subtract 4, then multiply by 2.',
        'answer': 10,
        'steps': [
          'x ÷ 2 + 4 - 4 = 9 - 4',
          'x ÷ 2 = 5',
          'x ÷ 2 × 2 = 5 × 2',
          'x = 10'
        ],
      },
    ],
    4: [
      // Expert - Variables on both sides
      {
        'equation': '2x + 3 = x + 7',
        'type': 'Both Sides',
        'hint': 'Subtract x from both sides, then subtract 3.',
        'answer': 4,
        'steps': [
          '2x + 3 - x = x + 7 - x',
          'x + 3 = 7',
          'x + 3 - 3 = 7 - 3',
          'x = 4'
        ],
      },
      {
        'equation': '3x - 2 = 2x + 3',
        'type': 'Both Sides',
        'hint': 'Subtract 2x from both sides, then add 2.',
        'answer': 5,
        'steps': [
          '3x - 2 - 2x = 2x + 3 - 2x',
          'x - 2 = 3',
          'x - 2 + 2 = 3 + 2',
          'x = 5'
        ],
      },
      {
        'equation': '4x + 1 = 3x + 6',
        'type': 'Both Sides',
        'hint': 'Subtract 3x from both sides, then subtract 1.',
        'answer': 5,
        'steps': [
          '4x + 1 - 3x = 3x + 6 - 3x',
          'x + 1 = 6',
          'x + 1 - 1 = 6 - 1',
          'x = 5'
        ],
      },
    ],
    5: [
      // Master - Complex equations
      {
        'equation': '2(x + 3) = 10',
        'type': 'Distributive',
        'hint': 'First distribute 2, then solve as a two-step equation.',
        'answer': 2,
        'steps': [
          '2x + 6 = 10',
          '2x + 6 - 6 = 10 - 6',
          '2x = 4',
          '2x ÷ 2 = 4 ÷ 2',
          'x = 2'
        ],
      },
      {
        'equation': '3x + 2 = 2x + 8',
        'type': 'Both Sides',
        'hint': 'Subtract 2x from both sides, then subtract 2.',
        'answer': 6,
        'steps': [
          '3x + 2 - 2x = 2x + 8 - 2x',
          'x + 2 = 8',
          'x + 2 - 2 = 8 - 2',
          'x = 6'
        ],
      },
      {
        'equation': 'x ÷ 3 + 2 = 5',
        'type': 'Two-Step',
        'hint': 'First subtract 2, then multiply by 3.',
        'answer': 9,
        'steps': [
          'x ÷ 3 + 2 - 2 = 5 - 2',
          'x ÷ 3 = 3',
          'x ÷ 3 × 3 = 3 × 3',
          'x = 9'
        ],
      },
    ],
  };

  // Constructor for backward compatibility (uses hardcoded data)
  SimpleEquationsGame() {
    _useDatabase = false;
    _loadChallenge();
  }

  // Constructor for database-driven data
  SimpleEquationsGame.withDatabase(GameDataService gameDataService) {
    _gameDataService = gameDataService;
    _useDatabase = true;
    _loadChallenge();
  }

  void _loadChallenge() async {
    if (_useDatabase && _gameDataService != null) {
      await _loadChallengeFromDatabase();
    } else {
      _loadChallengeFromHardcoded();
    }
  }

  void _loadChallengeFromHardcoded() {
    final levelEquations =
        _levelEquations[_currentLevel] ?? _levelEquations[1]!;
    final challengeData = levelEquations[_currentIndex % levelEquations.length];
    _currentEquation = challengeData['equation'];
    _hint = challengeData['hint'];
    _equationType = challengeData['type'];
    _answer = challengeData['answer'];
  }

  Future<void> _loadChallengeFromDatabase() async {
    try {
      // Get levels for the game
      final levels = await _gameDataService!.getLevels('simple-equations');
      if (levels.isEmpty) {
        // Fallback to hardcoded data
        _useDatabase = false;
        _loadChallengeFromHardcoded();
        return;
      }

      // Find the current level
      final currentLevelData = levels.firstWhere(
        (level) => level.levelNumber == _currentLevel,
        orElse: () => levels.first,
      );
      _currentLevelId = currentLevelData.id;

      // Get challenges for this level
      _currentChallenges =
          await _gameDataService!.getChallenges(_currentLevelId!);
      if (_currentChallenges!.isEmpty) {
        // Fallback to hardcoded data
        _useDatabase = false;
        _loadChallengeFromHardcoded();
        return;
      }

      // Get current challenge
      final challenge =
          _currentChallenges![_currentIndex % _currentChallenges!.length];
      _currentEquation = challenge.question;
      _hint = challenge.hint ?? 'Think about the equation carefully.';
      _answer = int.tryParse(challenge.answer) ?? 0;
      _equationType = 'Database';
    } catch (e) {
      print('Error loading challenge from database: $e');
      // Fallback to hardcoded data
      _useDatabase = false;
      _loadChallengeFromHardcoded();
    }
  }

  @override
  String get title => 'Simple Equations';

  @override
  String get id => 'simple-equations';

  @override
  IconData get icon => Icons.functions;

  @override
  String get description => 'Solve for x in the equation.';

  @override
  GameChallenge getChallenge() {
    return GameChallenge(question: 'Solve: $_currentEquation', data: {
      'equation': _currentEquation,
      'level': _currentLevel,
      'type': _equationType,
      'useDatabase': _useDatabase,
    });
  }

  @override
  bool checkAnswer(String answer) {
    return answer.trim() == _answer.toString();
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

  // Database-specific methods
  bool get useDatabase => _useDatabase;

  String? get currentLevelId => _currentLevelId;

  List<Challenge>? get currentChallenges => _currentChallenges;

  // Save progress to database
  Future<bool> saveProgress(String userId, int score, bool completed,
      {int? timeSeconds, int attempts = 1}) async {
    if (!_useDatabase || _gameDataService == null || _currentLevelId == null) {
      return false;
    }

    return await _gameDataService!.saveUserProgress(
      userId: userId,
      gameId: id,
      levelId: _currentLevelId!,
      score: score,
      completed: completed,
      timeSeconds: timeSeconds,
      attempts: attempts,
    );
  }

  // Get available levels for this game
  static List<int> getAvailableLevels() {
    return _levelEquations.keys.toList();
  }

  // Get level information
  static Map<String, dynamic> getLevelInfo(int level) {
    final equations = _levelEquations[level];
    if (equations == null) return {};

    return {
      'level': level,
      'difficulty': _getDifficultyName(level),
      'equationCount': equations.length,
      'types': equations.map((e) => e['type']).toSet().toList(),
    };
  }

  static String _getDifficultyName(int level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      case 4:
        return 'Expert';
      case 5:
        return 'Master';
      default:
        return 'Unknown';
    }
  }

  // Get level description
  static String getLevelDescription(int level) {
    switch (level) {
      case 1:
        return 'Simple addition and subtraction equations.';
      case 2:
        return 'Multiplication and division equations.';
      case 3:
        return 'Two-step equations requiring multiple operations.';
      case 4:
        return 'Equations with variables on both sides.';
      case 5:
        return 'Complex equations with distributive property.';
      default:
        return 'Unknown level.';
    }
  }

  // Get solution steps for current equation
  List<String> getSolutionSteps() {
    final levelEquations =
        _levelEquations[_currentLevel] ?? _levelEquations[1]!;
    final challengeData = levelEquations[_currentIndex % levelEquations.length];
    return List<String>.from(challengeData['steps'] ?? []);
  }
}
