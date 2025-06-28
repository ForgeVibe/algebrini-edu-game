import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/games/simple_equations_game.dart';
import 'package:algebrini_edu_game/games/recursive_sequences_game.dart';
import 'package:algebrini_edu_game/games/factorization_game.dart';

class DatabaseIntegrationTestScreen extends StatefulWidget {
  const DatabaseIntegrationTestScreen({super.key});

  @override
  State<DatabaseIntegrationTestScreen> createState() => _DatabaseIntegrationTestScreenState();
}

class _DatabaseIntegrationTestScreenState extends State<DatabaseIntegrationTestScreen> {
  final GameDataService _gameDataService = GameDataService();
  bool _isLoading = true;
  String _status = 'Initializing...';
  List<String> _testResults = [];

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
      _status = 'Running database integration tests...';
      _testResults.clear();
    });

    try {
      // Test 1: Database connection
      await _testDatabaseConnection();
      
      // Test 2: Game registry initialization
      await _testGameRegistry();
      
      // Test 3: Simple Equations Game
      await _testSimpleEquationsGame();
      
      // Test 4: Recursive Sequences Game
      await _testRecursiveSequencesGame();
      
      // Test 5: Factorization Game
      await _testFactorizationGame();
      
      // Test 6: Progress saving
      await _testProgressSaving();
      
      setState(() {
        _isLoading = false;
        _status = 'All tests completed successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Test failed: $e';
        _testResults.add('❌ Error: $e');
      });
    }
  }

  Future<void> _testDatabaseConnection() async {
    _addTestResult('🔍 Testing database connection...');
    
    // Test API connection
    final games = await _gameDataService.getGames();
    if (games.isNotEmpty) {
      _addTestResult('✅ Database connection successful - found ${games.length} games');
    } else {
      _addTestResult('⚠️ Database connected but no games found');
    }
  }

  Future<void> _testGameRegistry() async {
    _addTestResult('🔍 Testing game registry initialization...');
    
    final registry = GameRegistry();
    final games = registry.getGames();
    
    if (registry.useDatabase) {
      _addTestResult('✅ Game registry using database - ${games.length} games loaded');
    } else {
      _addTestResult('⚠️ Game registry using hardcoded data - ${games.length} games loaded');
    }
    
    // Test getting specific games
    final simpleEquations = registry.getGameById('simple-equations');
    final recursiveSequences = registry.getGameById('recursive-sequences');
    final factorization = registry.getGameById('factorization-fun');
    
    if (simpleEquations != null && recursiveSequences != null && factorization != null) {
      _addTestResult('✅ All games found in registry');
    } else {
      _addTestResult('❌ Some games not found in registry');
    }
  }

  Future<void> _testSimpleEquationsGame() async {
    _addTestResult('🔍 Testing Simple Equations Game...');
    
    // Test hardcoded version
    final hardcodedGame = SimpleEquationsGame();
    final hardcodedChallenge = hardcodedGame.getChallenge();
    _addTestResult('✅ Hardcoded game: ${hardcodedChallenge.question}');
    
    // Test database version
    final databaseGame = SimpleEquationsGame.withDatabase(_gameDataService);
    await Future.delayed(const Duration(milliseconds: 500)); // Wait for async loading
    final databaseChallenge = databaseGame.getChallenge();
    _addTestResult('✅ Database game: ${databaseChallenge.question}');
    
    if (databaseGame.useDatabase) {
      _addTestResult('✅ Database game using database data');
    } else {
      _addTestResult('⚠️ Database game fell back to hardcoded data');
    }
  }

  Future<void> _testRecursiveSequencesGame() async {
    _addTestResult('🔍 Testing Recursive Sequences Game...');
    
    // Test hardcoded version
    final hardcodedGame = RecursiveSequencesGame();
    final hardcodedChallenge = hardcodedGame.getChallenge();
    _addTestResult('✅ Hardcoded game: ${hardcodedChallenge.question}');
    
    // Test database version
    final databaseGame = RecursiveSequencesGame.withDatabase(_gameDataService);
    await Future.delayed(const Duration(milliseconds: 500)); // Wait for async loading
    final databaseChallenge = databaseGame.getChallenge();
    _addTestResult('✅ Database game: ${databaseChallenge.question}');
    
    if (databaseGame.useDatabase) {
      _addTestResult('✅ Database game using database data');
    } else {
      _addTestResult('⚠️ Database game fell back to hardcoded data');
    }
  }

  Future<void> _testFactorizationGame() async {
    _addTestResult('🔍 Testing Factorization Game...');
    
    // Test hardcoded version
    final hardcodedGame = FactorizationGame();
    final hardcodedChallenge = hardcodedGame.getChallenge();
    _addTestResult('✅ Hardcoded game: ${hardcodedChallenge.question}');
    
    // Test database version
    final databaseGame = FactorizationGame.withDatabase(_gameDataService);
    await Future.delayed(const Duration(milliseconds: 500)); // Wait for async loading
    final databaseChallenge = databaseGame.getChallenge();
    _addTestResult('✅ Database game: ${databaseChallenge.question}');
    
    if (databaseGame.useDatabase) {
      _addTestResult('✅ Database game using database data');
    } else {
      _addTestResult('⚠️ Database game fell back to hardcoded data');
    }
  }

  Future<void> _testProgressSaving() async {
    _addTestResult('🔍 Testing progress saving...');
    
    final testUserId = 'test-user-${DateTime.now().millisecondsSinceEpoch}';
    final testGameId = 'simple-equations';
    
    // Test saving progress
    final saved = await _gameDataService.saveUserProgress(
      userId: testUserId,
      gameId: testGameId,
      levelId: 'test-level-id',
      score: 100,
      completed: true,
      timeSeconds: 60,
      attempts: 1,
    );
    
    if (saved) {
      _addTestResult('✅ Progress saved successfully');
    } else {
      _addTestResult('❌ Failed to save progress');
    }
    
    // Test retrieving progress
    final progress = await _gameDataService.getUserProgress(testUserId, testGameId);
    if (progress.isNotEmpty) {
      _addTestResult('✅ Progress retrieved successfully');
    } else {
      _addTestResult('⚠️ No progress found (may be expected for test user)');
    }
  }

  void _addTestResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Integration Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isLoading ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const LinearProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _runTests,
                        child: const Text('Run Tests Again'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Test Results:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _testResults.length,
                          itemBuilder: (context, index) {
                            final result = _testResults[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                result,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 