import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/game_stats_service.dart';
import 'package:provider/provider.dart';
import '../services/font_size_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/analytics_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoaded = false;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _analyticsEvents = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final stats = await GameStatsService.getStats();
    final analyticsEvents = await AnalyticsService.getEvents();
    setState(() {
      _stats = stats;
      _analyticsEvents = analyticsEvents.reversed.take(10).toList();
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
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final useDyslexiaFont = fontSizeProvider.dyslexiaFont;
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
              style: useDyslexiaFont
                  ? GoogleFonts.lexend(fontSize: fontSizeProvider.fontSize + 4)
                  : Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: fontSizeProvider.fontSize + 4),
            ),
            const SizedBox(height: 24),

            // Overall Statistics
            _buildStatCard(
              'Overall Statistics',
              [
                _buildStatRow(
                    'Games Played',
                    '${_stats['totalGamesPlayed'] ?? 0}',
                    useDyslexiaFont,
                    fontSizeProvider),
                _buildStatRow(
                    'Total Questions',
                    '${_stats['totalAnswers'] ?? 0}',
                    useDyslexiaFont,
                    fontSizeProvider),
                _buildStatRow(
                    'Correct Answers',
                    '${_stats['correctAnswers'] ?? 0}',
                    useDyslexiaFont,
                    fontSizeProvider),
                _buildStatRow(
                    'Accuracy',
                    '${((_stats['totalAnswers'] ?? 0) == 0 ? 0.0 : ((_stats['correctAnswers'] ?? 0) / (_stats['totalAnswers'] ?? 1)) * 100).toStringAsFixed(1)}%',
                    useDyslexiaFont,
                    fontSizeProvider),
              ],
              Colors.blue,
              useDyslexiaFont,
              fontSizeProvider,
            ),

            const SizedBox(height: 16),

            // Game-specific Progress
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Sequences',
                    [
                      _buildStatRow(
                          'Completed',
                          '${_stats['sequencesCompleted'] ?? 0}',
                          useDyslexiaFont,
                          fontSizeProvider),
                    ],
                    Colors.green,
                    useDyslexiaFont,
                    fontSizeProvider,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Equations',
                    [
                      _buildStatRow(
                          'Completed',
                          '${_stats['equationsCompleted'] ?? 0}',
                          useDyslexiaFont,
                          fontSizeProvider),
                    ],
                    Colors.orange,
                    useDyslexiaFont,
                    fontSizeProvider,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Streaks
            _buildStatCard(
              'Streaks',
              [
                _buildStatRow(
                    'Current Streak',
                    '${_stats['currentStreak'] ?? 0}',
                    useDyslexiaFont,
                    fontSizeProvider),
                _buildStatRow('Best Streak', '${_stats['bestStreak'] ?? 0}',
                    useDyslexiaFont, fontSizeProvider),
              ],
              Colors.purple,
              useDyslexiaFont,
              fontSizeProvider,
            ),

            const SizedBox(height: 16),

            // Last Played
            _buildStatCard(
              'Recent Activity',
              [
                _buildStatRow('Last Played', _stats['lastPlayed'] ?? '-',
                    useDyslexiaFont, fontSizeProvider),
              ],
              Colors.teal,
              useDyslexiaFont,
              fontSizeProvider,
            ),

            const SizedBox(height: 24),

            // Analytics section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Activity',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.download),
                              tooltip: 'Export CSV',
                              onPressed: () async {
                                final csv =
                                    await AnalyticsService.exportAsCSV();
                                // TODO: Implement file save/share
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('CSV exported (see logs)')));
                                print(csv);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.code),
                              tooltip: 'Export JSON',
                              onPressed: () async {
                                final json =
                                    await AnalyticsService.exportAsJSON();
                                // TODO: Implement file save/share
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('JSON exported (see logs)')));
                                print(json);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _analyticsEvents.isEmpty
                        ? Text('No recent activity')
                        : Column(
                            children: _analyticsEvents
                                .map((e) => ListTile(
                                      dense: true,
                                      leading: Icon(Icons.event_note),
                                      title: Text('${e['type']}'),
                                      subtitle: Text(
                                          '${e['timestamp']}\n${e['details'] ?? ''}'),
                                    ))
                                .toList(),
                          ),
                  ],
                ),
              ),
            ),

            // Achievements
            _buildAchievementsSection(fontSizeProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, List<Widget> children, Color color,
      bool useDyslexiaFont, FontSizeProvider fontSizeProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: useDyslexiaFont
                  ? GoogleFonts.lexend(
                      fontSize: fontSizeProvider.fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: color)
                  : TextStyle(
                      fontSize: fontSizeProvider.fontSize + 2,
                      fontWeight: FontWeight.bold,
                      color: color),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, bool useDyslexiaFont,
      FontSizeProvider fontSizeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: useDyslexiaFont
                ? GoogleFonts.lexend(fontSize: 16)
                : const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: useDyslexiaFont
                ? GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold)
                : const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(FontSizeProvider fontSizeProvider) {
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
                    fontSize: fontSizeProvider.fontSize + 2,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...achievements.map((achievement) =>
                _buildAchievementTile(achievement, fontSizeProvider)),
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
        'unlocked': (_stats['totalGamesPlayed'] ?? 0) > 0,
        'color': Colors.green,
      },
      {
        'title': 'Accuracy Master',
        'description': 'Achieve 90% accuracy',
        'icon': Icons.track_changes,
        'unlocked': (((_stats['totalAnswers'] ?? 0) == 0
                ? 0.0
                : ((_stats['correctAnswers'] ?? 0) /
                        (_stats['totalAnswers'] ?? 1)) *
                    100) >=
            90),
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

  Widget _buildAchievementTile(
      Map<String, dynamic> achievement, FontSizeProvider fontSizeProvider) {
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
                    fontSize: fontSizeProvider.fontSize,
                  ),
                ),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize - 4,
                    color:
                        achievement['unlocked'] ? Colors.black54 : Colors.grey,
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
