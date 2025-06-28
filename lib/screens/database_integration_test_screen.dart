import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_data_service.dart';
import '../games/database_game_factory.dart';
import '../games/simple_equations_game.dart';
import '../models/database_models.dart';

class DatabaseIntegrationTestScreen extends StatefulWidget {
  const DatabaseIntegrationTestScreen({super.key});

  @override
  State<DatabaseIntegrationTestScreen> createState() => _DatabaseIntegrationTestScreenState();
}

class _DatabaseIntegrationTestScreenState extends State<DatabaseIntegrationTestScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test';
  List<Game> _games = [];
  List<Level> _levels = [];
  List<Challenge> _challenges = [];
  SimpleEquationsGame? _databaseGame;
  SimpleEquationsGame? _hardcodedGame;
  String _testUserId = 'test_user_123';

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status: $_status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const LinearProgressIndicator()
                    else
                      const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDatabaseConnection,
                    child: const Text('Test DB Connection'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGameCreation,
                    child: const Text('Test Game Creation'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testGameComparison,
                    child: const Text('Compare Games'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testProgressSaving,
                    child: const Text('Test Progress'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _testAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Run All Tests'),
            ),
            
            const SizedBox(height: 16),
            
            // Results display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_games.isNotEmpty) ...[
                      _buildSection('Games (${_games.length})', _games.map((game) => 
                        '${game.name} - ${game.difficultyLevels} levels'
                      ).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_levels.isNotEmpty) ...[
                      _buildSection('Levels (${_levels.length})', _levels.map((level) => 
                        'Level ${level.levelNumber} - ${level.difficulty.name}'
                      ).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_challenges.isNotEmpty) ...[
                      _buildSection('Challenges (${_challenges.length})', _challenges.map((challenge) => 
                        '${challenge.question.substring(0, challenge.question.length > 30 ? 30 : challenge.question.length)}...'
                      ).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_databaseGame != null) ...[
                      _buildSection('Database Game', [
                        'Title: ${_databaseGame!.title}',
                        'ID: ${_databaseGame!.id}',
                        'Uses Database: ${_databaseGame!.useDatabase}',
                        'Current Level: ${_databaseGame!.currentLevel}',
                        'Current Challenge: ${_databaseGame!.getChallenge().question}',
                      ]),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_hardcodedGame != null) ...[
                      _buildSection('Hardcoded Game', [
                        'Title: ${_hardcodedGame!.title}',
                        'ID: ${_hardcodedGame!.id}',
                        'Uses Database: ${_hardcodedGame!.useDatabase}',
                        'Current Level: ${_hardcodedGame!.currentLevel}',
                        'Current Challenge: ${_hardcodedGame!.getChallenge().question}',
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text('• $item'),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing database connection...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      final games = await gameDataService.getGames();
      
      setState(() {
        _games = games;
        _status = 'Database connection successful: ${games.length} games found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Database connection failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGameCreation() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing game creation...';
    });

    try {
      // Test database game creation
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      _databaseGame = SimpleEquationsGame.withDatabase(gameDataService);
      
      // Test hardcoded game creation
      _hardcodedGame = SimpleEquationsGame();
      
      // Get levels and challenges
      final levels = await gameDataService.getLevels('simple-equations');
      final challenges = levels.isNotEmpty ? await gameDataService.getChallenges(levels.first.id) : [];
      
      setState(() {
        _levels = levels;
        _challenges = challenges;
        _status = 'Game creation successful - Database: ${_databaseGame!.useDatabase}, Hardcoded: ${_hardcodedGame!.useDatabase}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Game creation failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testGameComparison() async {
    if (_databaseGame == null || _hardcodedGame == null) {
      setState(() {
        _status = 'Please create games first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Comparing games...';
    });

    try {
      final dbChallenge = _databaseGame!.getChallenge();
      final hardcodedChallenge = _hardcodedGame!.getChallenge();
      
      setState(() {
        _status = 'Comparison complete - Database: ${dbChallenge.question}, Hardcoded: ${hardcodedChallenge.question}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Game comparison failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testProgressSaving() async {
    if (_databaseGame == null) {
      setState(() {
        _status = 'Please create database game first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Testing progress saving...';
    });

    try {
      final success = await _databaseGame!.saveProgress(_testUserId, 100, true, timeSeconds: 60);
      
      setState(() {
        _status = success ? 'Progress saved successfully' : 'Progress saving failed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Progress saving failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAll() async {
    setState(() {
      _isLoading = true;
      _status = 'Running all tests...';
    });

    try {
      await _testDatabaseConnection();
      await _testGameCreation();
      await _testGameComparison();
      await _testProgressSaving();
      
      setState(() {
        _status = 'All tests completed successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Some tests failed: $e';
        _isLoading = false;
      });
    }
  }
} 