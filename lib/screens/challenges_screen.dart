import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/services/challenge_service.dart';
import 'package:algebrini_edu_game/services/rewards_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/font_size_provider.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _dailyChallenge;
  Map<String, dynamic>? _weeklyChallenge;
  Map<String, dynamic> _challengeStats = {};
  List<Map<String, dynamic>> _challengeHistory = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dailyChallenge = await ChallengeService.getCurrentDailyChallenge();
      final weeklyChallenge = await ChallengeService.getCurrentWeeklyChallenge();
      final challengeStats = await ChallengeService.getChallengeStats();
      final challengeHistory = await ChallengeService.getChallengeHistory();

      setState(() {
        _dailyChallenge = dailyChallenge;
        _weeklyChallenge = weeklyChallenge;
        _challengeStats = challengeStats;
        _challengeHistory = challengeHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading challenges: $e')),
        );
      }
    }
  }

  Future<void> _claimReward(String challengeId, bool isWeekly) async {
    final success = await ChallengeService.claimChallengeReward(challengeId, isWeekly);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reward claimed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadChallenges(); // Refresh data
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim reward'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'orange': return Colors.orange;
      case 'gold': return Colors.amber;
      case 'purple': return Colors.purple;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'red': return Colors.red;
      case 'teal': return Colors.teal;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Challenges',
          style: GoogleFonts.baloo2(
            fontSize: fontSizeProvider.fontSize + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade100,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.baloo2(fontSize: fontSizeProvider.fontSize),
          tabs: const [
            Tab(text: 'Daily', icon: Icon(Icons.today)),
            Tab(text: 'Weekly', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'History', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDailyChallengesTab(fontSizeProvider),
                _buildWeeklyChallengesTab(fontSizeProvider),
                _buildHistoryTab(fontSizeProvider),
              ],
            ),
    );
  }

  Widget _buildDailyChallengesTab(FontSizeProvider fontSizeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.blue.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, size: 48, color: Colors.blue.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Challenges Completed',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        Text(
                          '${_challengeStats['dailyCompleted'] ?? 0}',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize + 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Current daily challenge
          if (_dailyChallenge != null) ...[
            Text(
              "Today's Challenge",
              style: GoogleFonts.baloo2(
                fontSize: fontSizeProvider.fontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChallengeCard(_dailyChallenge!, false, fontSizeProvider),
          ] else ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No daily challenge available',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeeklyChallengesTab(FontSizeProvider fontSizeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.purple.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, size: 48, color: Colors.purple.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Challenges Completed',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        Text(
                          '${_challengeStats['weeklyCompleted'] ?? 0}',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize + 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Current weekly challenge
          if (_weeklyChallenge != null) ...[
            Text(
              "This Week's Challenge",
              style: GoogleFonts.baloo2(
                fontSize: fontSizeProvider.fontSize + 4,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChallengeCard(_weeklyChallenge!, true, fontSizeProvider),
          ] else ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No weekly challenge available',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab(FontSizeProvider fontSizeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.green.shade100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.star, size: 48, color: Colors.green.shade700),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Rewards Earned',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        Text(
                          '${_challengeStats['totalRewards']?['coins'] ?? 0} coins, ${_challengeStats['totalRewards']?['stars'] ?? 0} stars',
                          style: GoogleFonts.baloo2(
                            fontSize: fontSizeProvider.fontSize + 4,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Recent Challenges',
            style: GoogleFonts.baloo2(
              fontSize: fontSizeProvider.fontSize + 4,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (_challengeHistory.isEmpty)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No completed challenges yet',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            )
          else
            ..._challengeHistory.take(10).map((challenge) => 
              _buildHistoryCard(challenge, fontSizeProvider)
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge, bool isWeekly, FontSizeProvider fontSizeProvider) {
    final color = _getColorFromString(challenge['color']);
    final progress = challenge['progress'] as int;
    final completed = challenge['completed'] as bool;
    final claimed = challenge['claimed'] as bool;
    final reward = challenge['reward'] as Map<String, dynamic>;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  challenge['icon'],
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge['title'],
                        style: GoogleFonts.baloo2(
                          fontSize: fontSizeProvider.fontSize + 2,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        challenge['description'],
                        style: GoogleFonts.baloo2(
                          fontSize: fontSizeProvider.fontSize,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: color.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              '$progress% Complete',
              style: GoogleFonts.baloo2(
                fontSize: fontSizeProvider.fontSize - 2,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            
            // Reward section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: color),
                  const SizedBox(width: 8),
                  Text(
                    'Reward: ${reward['coins']} coins, ${reward['stars']} stars',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action button
            if (completed && !claimed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => _claimReward(challenge['id'], isWeekly),
                  child: const Text('Claim Reward'),
                ),
              )
            else if (claimed)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Center(
                  child: Text(
                    'Reward Claimed!',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey),
                ),
                child: Center(
                  child: Text(
                    'Keep playing to complete!',
                    style: GoogleFonts.baloo2(
                      fontSize: fontSizeProvider.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> challenge, FontSizeProvider fontSizeProvider) {
    final color = _getColorFromString(challenge['color']);
    final completedAt = DateTime.parse(challenge['completedAt']);
    final isWeekly = challenge['isWeekly'] as bool;
    final reward = challenge['reward'] as Map<String, dynamic>;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            challenge['icon'],
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          challenge['title'],
          style: GoogleFonts.baloo2(
            fontSize: fontSizeProvider.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              challenge['description'],
              style: GoogleFonts.baloo2(fontSize: fontSizeProvider.fontSize - 2),
            ),
            Text(
              'Completed: ${completedAt.day}/${completedAt.month}/${completedAt.year}',
              style: GoogleFonts.baloo2(
                fontSize: fontSizeProvider.fontSize - 4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${reward['coins']}c ${reward['stars']}⭐',
            style: GoogleFonts.baloo2(
              fontSize: fontSizeProvider.fontSize - 2,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
} 