import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/game_data_service.dart';
import '../models/database_models.dart';

class DatabaseTestScreen extends StatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  State<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends State<DatabaseTestScreen> {
  bool _isLoading = false;
  String _status = 'Ready to test';
  List<Game> _games = [];
  List<Chapter> _chapters = [];
  List<Realm> _realms = [];
  List<Achievement> _achievements = [];

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
                    onPressed: _isLoading ? null : _testGames,
                    child: const Text('Test Games'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testChapters,
                    child: const Text('Test Chapters'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testRealms,
                    child: const Text('Test Realms'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testAchievements,
                    child: const Text('Test Achievements'),
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
              child: const Text('Test All'),
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
                    
                    if (_chapters.isNotEmpty) ...[
                      _buildSection('Chapters (${_chapters.length})', _chapters.map((chapter) => 
                        '${chapter.title} - ${chapter.games.length} games'
                      ).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_realms.isNotEmpty) ...[
                      _buildSection('Realms (${_realms.length})', _realms.map((realm) => 
                        '${realm.name} - ${realm.description ?? 'No description'}'
                      ).toList()),
                      const SizedBox(height: 16),
                    ],
                    
                    if (_achievements.isNotEmpty) ...[
                      _buildSection('Achievements (${_achievements.length})', _achievements.map((achievement) => 
                        '${achievement.title} - ${achievement.points} points'
                      ).toList()),
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

  Future<void> _testGames() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing games...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      final games = await gameDataService.getGames();
      
      setState(() {
        _games = games;
        _status = 'Games test completed: ${games.length} games found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Games test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testChapters() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing chapters...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      final chapters = await gameDataService.getChapters();
      
      setState(() {
        _chapters = chapters;
        _status = 'Chapters test completed: ${chapters.length} chapters found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Chapters test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testRealms() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing realms...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      final realms = await gameDataService.getRealms();
      
      setState(() {
        _realms = realms;
        _status = 'Realms test completed: ${realms.length} realms found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Realms test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAchievements() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing achievements...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      final achievements = await gameDataService.getAchievements();
      
      setState(() {
        _achievements = achievements;
        _status = 'Achievements test completed: ${achievements.length} achievements found';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Achievements test failed: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testAll() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing all data...';
    });

    try {
      final gameDataService = Provider.of<GameDataService>(context, listen: false);
      
      final futures = await Future.wait([
        gameDataService.getGames(),
        gameDataService.getChapters(),
        gameDataService.getRealms(),
        gameDataService.getAchievements(),
      ]);
      
      setState(() {
        _games = futures[0] as List<Game>;
        _chapters = futures[1] as List<Chapter>;
        _realms = futures[2] as List<Realm>;
        _achievements = futures[3] as List<Achievement>;
        _status = 'All tests completed successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'All tests failed: $e';
        _isLoading = false;
      });
    }
  }
} 