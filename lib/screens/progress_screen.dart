import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/game_stats_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoaded = false;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final stats = await GameStatsService.getStats();
    setState(() {
      _stats = stats;
      _isLoaded = true;
    });
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
            Text(
              loc.progress,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            
            // Overall Statistics
            _buildStatCard(
              'Overall Statistics',
              [
                _buildStatRow('Games Played', '${_stats['totalGamesPlayed']}'),
                _buildStatRow('Total Questions', '${_stats['totalAnswers']}'),
                _buildStatRow('Correct Answers', '${_stats['correctAnswers']}'),
                _buildStatRow('Accuracy', '${_accuracy.toStringAsFixed(1)}%'),
              ],
              Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // Game-specific Progress
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Sequences',
                    [
                      _buildStatRow('Completed', '${_stats['sequencesCompleted']}'),
                    ],
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Equations',
                    [
                      _buildStatRow('Completed', '${_stats['equationsCompleted']}'),
                    ],
                    Colors.orange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Streaks
            _buildStatCard(
              'Streaks',
              [
                _buildStatRow('Current Streak', '${_stats['currentStreak']}'),
                _buildStatRow('Best Streak', '${_stats['bestStreak']}'),
              ],
              Colors.purple,
            ),
            
            const SizedBox(height: 16),
            
            // Last Played
            _buildStatCard(
              'Recent Activity',
              [
                _buildStatRow('Last Played', _stats['lastPlayed']),
              ],
              Colors.teal,
            ),
            
            const SizedBox(height: 24),
            
            // Achievements
            _buildAchievementsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> children, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = _getAchievements();
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...achievements.map((achievement) => _buildAchievementTile(achievement)),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements() {
    return [
      {
        'title': 'First Steps',
        'description': 'Complete your first game',
        'icon': Icons.star,
        'unlocked': _stats['totalGamesPlayed'] > 0,
        'color': Colors.green,
      },
      {
        'title': 'Accuracy Master',
        'description': 'Achieve 90% accuracy',
        'icon': Icons.track_changes,
        'unlocked': _accuracy >= 90,
        'color': Colors.blue,
      },
      {
        'title': 'Streak Champion',
        'description': 'Get a 10-question streak',
        'icon': Icons.local_fire_department,
        'unlocked': _stats['bestStreak'] >= 10,
        'color': Colors.orange,
      },
      {
        'title': 'Dedicated Learner',
        'description': 'Play 50 games',
        'icon': Icons.school,
        'unlocked': _stats['totalGamesPlayed'] >= 50,
        'color': Colors.purple,
      },
    ];
  }

  Widget _buildAchievementTile(Map<String, dynamic> achievement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            achievement['icon'],
            color: achievement['unlocked'] ? achievement['color'] : Colors.grey,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: achievement['unlocked'] ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement['unlocked'] ? Colors.black54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            achievement['unlocked'] ? Icons.check_circle : Icons.lock,
            color: achievement['unlocked'] ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }
} 