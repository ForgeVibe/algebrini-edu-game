import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_stats_service.dart';
import 'package:google_fonts/google_fonts.dart';

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

    // Use a playful background color
    return Container(
      color: Colors.purple.shade50,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Playful Welcome Section
              _buildPlayfulWelcomeSection(loc),
              const SizedBox(height: 24),
              // Playful Quick Stats
              _buildPlayfulQuickStatsSection(),
              const SizedBox(height: 24),
              // Playful Quick Access to Games
              _buildPlayfulQuickAccessSection(loc),
              const SizedBox(height: 24),
              // Recent Activity
              if (_recentActivity.isNotEmpty) ...[
                _buildRecentActivitySection(),
                const SizedBox(height: 24),
              ],
              // Daily Challenge
              _buildPlayfulDailyChallengeSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Playful Welcome Section with large mascot icon and friendly font
  Widget _buildPlayfulWelcomeSection(AppLocalizations loc) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.deepPurple.shade400,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Row(
          children: [
            // Mascot or playful icon
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.emoji_emotions,
                size: 48,
                color: Colors.deepPurple.shade400,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $_username!',
                    style: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ready for some magical math adventures?',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Playful Quick Stats Section
  Widget _buildPlayfulQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildPlayfulStatCard(
            'Games',
            '${_stats['totalGamesPlayed']}',
            Icons.videogame_asset,
            Colors.green.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlayfulStatCard(
            'Accuracy',
            '${_accuracy.toStringAsFixed(1)}%',
            Icons.track_changes,
            Colors.blue.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlayfulStatCard(
            'Streak',
            '${_stats['currentStreak']}',
            Icons.local_fire_department,
            Colors.orange.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayfulStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.baloo2(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.baloo2(
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Playful Quick Access Section
  Widget _buildPlayfulQuickAccessSection(AppLocalizations loc) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.purple.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPlayfulQuickAccessButton(
              icon: Icons.play_circle_fill,
              label: loc.play,
              color: Colors.deepPurple.shade400,
              onTap: () => Navigator.pushNamed(context, '/play'),
            ),
            _buildPlayfulQuickAccessButton(
              icon: Icons.emoji_events,
              label: 'Progress',
              color: Colors.amber.shade700,
              onTap: () => Navigator.pushNamed(context, '/progress'),
            ),
            _buildPlayfulQuickAccessButton(
              icon: Icons.settings,
              label: loc.settings,
              color: Colors.blue.shade400,
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayfulQuickAccessButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Playful Daily Challenge Section
  Widget _buildPlayfulDailyChallengeSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.pink.shade100,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.flash_on, color: Colors.pink.shade400, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Try today\'s Daily Challenge for a bonus reward!',
                style: GoogleFonts.baloo2(
                  fontSize: 18,
                  color: Colors.pink.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                textStyle: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pushNamed(context, '/play'),
              child: const Text('Play'),
            ),
          ],
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
} 