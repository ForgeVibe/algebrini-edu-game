import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_stats_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoaded = false;
  Map<String, dynamic> _stats = {};
  String _username = '';
  List<Map<String, dynamic>> _recentActivity = [];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await GameStatsService.getStats();
    
    setState(() {
      _username = prefs.getString('username') ?? 'Player';
      _stats = stats;
      _recentActivity = _getRecentActivity(stats);
      _isLoaded = true;
    });
  }

  List<Map<String, dynamic>> _getRecentActivity(Map<String, dynamic> stats) {
    final activities = <Map<String, dynamic>>[];
    
    // Add last played game if available
    final lastPlayed = stats['lastPlayed'];
    if (lastPlayed != null && lastPlayed != 'Never') {
      activities.add({
        'type': 'game_played',
        'title': 'Last Game Played',
        'description': lastPlayed,
        'icon': Icons.videogame_asset,
        'color': Colors.green,
        'time': 'Recently',
      });
    }

    // Add achievements if any
    final accuracy = stats['totalAnswers'] > 0 
        ? (stats['correctAnswers'] / stats['totalAnswers']) * 100 
        : 0.0;
    
    if (stats['totalGamesPlayed'] > 0) {
      activities.add({
        'type': 'achievement',
        'title': 'First Steps',
        'description': 'Completed your first game!',
        'icon': Icons.star,
        'color': Colors.amber,
        'time': 'Unlocked',
      });
    }

    if (accuracy >= 90 && stats['totalAnswers'] >= 10) {
      activities.add({
        'type': 'achievement',
        'title': 'Accuracy Master',
        'description': 'Achieved 90% accuracy!',
        'icon': Icons.track_changes,
        'color': Colors.blue,
        'time': 'Unlocked',
      });
    }

    if (stats['bestStreak'] >= 10) {
      activities.add({
        'type': 'achievement',
        'title': 'Streak Champion',
        'description': 'Got a 10-question streak!',
        'icon': Icons.local_fire_department,
        'color': Colors.orange,
        'time': 'Unlocked',
      });
    }

    return activities.take(3).toList();
  }

  double get _accuracy {
    if (_stats['totalAnswers'] == 0) return 0.0;
    return (_stats['correctAnswers'] / _stats['totalAnswers']) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(loc),
            
            const SizedBox(height: 24),
            
            // Quick Stats
            _buildQuickStatsSection(),
            
            const SizedBox(height: 24),
            
            // Quick Access to Games
            _buildQuickAccessSection(loc),
            
            const SizedBox(height: 24),
            
            // Recent Activity
            if (_recentActivity.isNotEmpty) ...[
              _buildRecentActivitySection(),
              const SizedBox(height: 24),
            ],
            
            // Daily Challenge
            _buildDailyChallengeSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AppLocalizations loc) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.deepPurple.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $_username!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ready to learn some algebra?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Games',
            '${_stats['totalGamesPlayed']}',
            Icons.videogame_asset,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Accuracy',
            '${_accuracy.toStringAsFixed(1)}%',
            Icons.track_changes,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Streak',
            '${_stats['currentStreak']}',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection(AppLocalizations loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Play',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGameCard(
                'Sequences',
                'Find the pattern in number sequences',
                Icons.timeline,
                Colors.deepPurple,
                () => _navigateToGame('sequences'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGameCard(
                'Equations',
                'Solve simple algebraic equations',
                Icons.functions,
                Colors.green,
                () => _navigateToGame('equations'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._recentActivity.map((activity) => _buildActivityTile(activity)),
      ],
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity['color'].withOpacity(0.2),
          child: Icon(
            activity['icon'],
            color: activity['color'],
          ),
        ),
        title: Text(
          activity['title'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(activity['description']),
        trailing: Text(
          activity['time'],
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyChallengeSection() {
    return Card(
      elevation: 3,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Daily Challenge',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Complete 5 questions today to earn bonus points!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _navigateToGame('daily'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange.shade600,
              ),
              child: const Text('Start Challenge'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(String gameType) {
    // Navigate to the play screen - the games will be accessible from there
    // For now, we'll just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $gameType game...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
} 