import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/game_stats_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoaded = false;
  String _selectedLanguage = 'en';
  String _difficulty = 'medium';
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _tutorialEnabled = true;
  bool _hintsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
      _difficulty = prefs.getString('difficulty') ?? 'medium';
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _tutorialEnabled = prefs.getBool('tutorialEnabled') ?? true;
      _hintsEnabled = prefs.getBool('hintsEnabled') ?? true;
      _isLoaded = true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', _selectedLanguage);
    await prefs.setString('difficulty', _difficulty);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('musicEnabled', _musicEnabled);
    await prefs.setBool('tutorialEnabled', _tutorialEnabled);
    await prefs.setBool('hintsEnabled', _hintsEnabled);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
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
              loc.settings,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            
            // Language Settings
            _buildSettingsCard(
              'Language & Localization',
              Icons.language,
              Colors.blue,
              [
                _buildDropdownSetting(
                  'Language',
                  _selectedLanguage,
                  {
                    'en': 'English',
                    'fr': 'Français',
                    'es': 'Español',
                    'de': 'Deutsch',
                  },
                  (value) => setState(() => _selectedLanguage = value!),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Game Settings
            _buildSettingsCard(
              'Game Settings',
              Icons.videogame_asset,
              Colors.green,
              [
                _buildDropdownSetting(
                  'Difficulty',
                  _difficulty,
                  {
                    'easy': 'Easy',
                    'medium': 'Medium',
                    'hard': 'Hard',
                  },
                  (value) => setState(() => _difficulty = value!),
                ),
                _buildSwitchSetting(
                  'Show Tutorials',
                  _tutorialEnabled,
                  (value) => setState(() => _tutorialEnabled = value),
                ),
                _buildSwitchSetting(
                  'Enable Hints',
                  _hintsEnabled,
                  (value) => setState(() => _hintsEnabled = value),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Audio Settings
            _buildSettingsCard(
              'Audio Settings',
              Icons.volume_up,
              Colors.orange,
              [
                _buildSwitchSetting(
                  'Sound Effects',
                  _soundEnabled,
                  (value) => setState(() => _soundEnabled = value),
                ),
                _buildSwitchSetting(
                  'Background Music',
                  _musicEnabled,
                  (value) => setState(() => _musicEnabled = value),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Data Management
            _buildSettingsCard(
              'Data Management',
              Icons.storage,
              Colors.red,
              [
                _buildButtonSetting(
                  'Reset Progress',
                  'Clear all game progress and statistics',
                  Icons.refresh,
                  () => _showResetProgressDialog(),
                ),
                _buildButtonSetting(
                  'Export Data',
                  'Save your progress to a file',
                  Icons.download,
                  () => _exportData(),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // About Section
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(String title, IconData icon, Color color, List<Widget> children) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSetting(String label, String value, Map<String, String> options, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            items: options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSetting(String label, String description, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'About Algebrini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'An educational game for learning algebra through interactive mini-games.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Progress'),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _resetProgress();
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetProgress() async {
    await GameStatsService.resetProgress();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress reset successfully!')),
    );
  }

  void _exportData() {
    // Placeholder for data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }
} 