import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/level_progression_service.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/database_models.dart';

class RecursiveSequencesGame implements MiniGame {
  int _currentIndex = 0;
  int _currentLevel = 1;
  late List<int> _currentSequence;
  late int _answer;
  late String _hint;
  late String _sequenceType;
  
  // Database support
  GameDataService? _gameDataService;
  String? _currentLevelId;
  List<Challenge>? _currentChallenges;
  bool _useDatabase = false;

  // Level-specific sequences with increasing difficulty
  static const Map<int, List<Map<String, dynamic>>> _levelSequences = {
    1: [ // Easy - Simple arithmetic sequences
      {
        'sequence': [2, 4, 6, 8, 10],
        'type': 'Arithmetic',
        'hint': 'Each number increases by 2.',
        'answer': 12,
      },
      {
        'sequence': [1, 3, 5, 7, 9],
        'type': 'Arithmetic',
        'hint': 'Each number increases by 2.',
        'answer': 11,
      },
      {
        'sequence': [5, 10, 15, 20, 25],
        'type': 'Arithmetic',
        'hint': 'Each number increases by 5.',
        'answer': 30,
      },
    ],
    2: [ // Medium - Geometric sequences
      {
        'sequence': [2, 4, 8, 16, 32],
        'type': 'Geometric',
        'hint': 'Each number is multiplied by 2.',
        'answer': 64,
      },
      {
        'sequence': [3, 6, 12, 24, 48],
        'type': 'Geometric',
        'hint': 'Each number is multiplied by 2.',
        'answer': 96,
      },
      {
        'sequence': [1, 3, 9, 27, 81],
        'type': 'Geometric',
        'hint': 'Each number is multiplied by 3.',
        'answer': 243,
      },
    ],
    3: [ // Hard - Fibonacci-like sequences
      {
        'sequence': [1, 1, 2, 3, 5],
        'type': 'Fibonacci',
        'hint': 'Each number is the sum of the previous two.',
        'answer': 8,
      },
      {
        'sequence': [2, 2, 4, 6, 10],
        'type': 'Fibonacci',
        'hint': 'Each number is the sum of the previous two.',
        'answer': 16,
      },
      {
        'sequence': [1, 2, 3, 5, 8],
        'type': 'Fibonacci',
        'hint': 'Each number is the sum of the previous two.',
        'answer': 13,
      },
    ],
    4: [ // Expert - Mixed patterns
      {
        'sequence': [1, 4, 9, 16, 25],
        'type': 'Square',
        'hint': 'Each number is a perfect square.',
        'answer': 36,
      },
      {
        'sequence': [2, 6, 12, 20, 30],
        'type': 'Triangular',
        'hint': 'Each number follows the pattern: n² + n.',
        'answer': 42,
      },
      {
        'sequence': [1, 2, 4, 7, 11],
        'type': 'Incremental',
        'hint': 'The difference between numbers increases by 1 each time.',
        'answer': 16,
      },
    ],
    5: [ // Master - Complex patterns
      {
        'sequence': [1, 3, 6, 10, 15],
        'type': 'Triangular',
        'hint': 'Each number is the sum of all previous numbers plus 1.',
        'answer': 21,
      },
      {
        'sequence': [2, 3, 5, 7, 11],
        'type': 'Prime',
        'hint': 'Each number is a prime number.',
        'answer': 13,
      },
      {
        'sequence': [1, 1, 2, 6, 24],
        'type': 'Factorial',
        'hint': 'Each number is the factorial of its position.',
        'answer': 120,
      },
    ],
  };

  // Constructor for backward compatibility (uses hardcoded data)
  RecursiveSequencesGame() {
    _useDatabase = false;
    _loadChallenge();
  }

  // Constructor for database-driven data
  RecursiveSequencesGame.withDatabase(GameDataService gameDataService) {
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
    final levelSequences = _levelSequences[_currentLevel] ?? _levelSequences[1]!;
    final challengeData = levelSequences[_currentIndex % levelSequences.length];
    _currentSequence = List<int>.from(challengeData['sequence']);
    _hint = challengeData['hint'];
    _sequenceType = challengeData['type'];
    _answer = challengeData['answer'];
  }

  Future<void> _loadChallengeFromDatabase() async {
    try {
      // Get levels for the game
      final levels = await _gameDataService!.getLevels('recursive-sequences');
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
      _currentChallenges = await _gameDataService!.getChallenges(_currentLevelId!);
      if (_currentChallenges!.isEmpty) {
        // Fallback to hardcoded data
        _useDatabase = false;
        _loadChallengeFromHardcoded();
        return;
      }

      // Get current challenge
      final challenge = _currentChallenges![_currentIndex % _currentChallenges!.length];
      
      // Parse sequence from challenge question (assuming format like "2, 4, 6, 8, 10")
      final sequenceStr = challenge.question.replaceAll('?', '').trim();
      _currentSequence = sequenceStr.split(',')
          .map((s) => int.tryParse(s.trim()) ?? 0)
          .where((n) => n > 0)
          .toList();
      
      _hint = challenge.hint ?? 'Look for the pattern in the sequence.';
      _answer = int.tryParse(challenge.answer) ?? 0;
      _sequenceType = 'Database';
    } catch (e) {
      print('Error loading challenge from database: $e');
      // Fallback to hardcoded data
      _useDatabase = false;
      _loadChallengeFromHardcoded();
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
    return GameChallenge(
      question: question, 
      data: {
        'sequence': _currentSequence,
        'level': _currentLevel,
        'type': _sequenceType,
        'useDatabase': _useDatabase,
      }
    );
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
  Future<bool> saveProgress(String userId, int score, bool completed, {int? timeSeconds, int attempts = 1}) async {
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
    return _levelSequences.keys.toList();
  }

  // Get level information
  static Map<String, dynamic> getLevelInfo(int level) {
    final sequences = _levelSequences[level];
    if (sequences == null) return {};
    
    return {
      'level': level,
      'difficulty': _getDifficultyName(level),
      'sequenceCount': sequences.length,
      'types': sequences.map((s) => s['type']).toSet().toList(),
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
      case 1: return 'Simple arithmetic sequences with constant differences.';
      case 2: return 'Geometric sequences with multiplication patterns.';
      case 3: return 'Fibonacci-like sequences where each number depends on previous ones.';
      case 4: return 'Mixed patterns including squares and triangular numbers.';
      case 5: return 'Complex patterns including primes and factorials.';
      default: return 'Unknown level.';
    }
  }
} 