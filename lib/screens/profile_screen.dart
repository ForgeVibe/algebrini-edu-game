import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/avatar_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/font_size_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/rewards_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController();
  int _selectedAvatar = 0;
  bool _isLoaded = false;
  int _coins = 0;
  int _stars = 0;
  List<String> _badges = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _selectedAvatar = prefs.getInt('avatarIndex') ?? 0;
      RewardsService.getCoins().then((c) => setState(() => _coins = c));
      RewardsService.getStars().then((s) => setState(() => _stars = s));
      RewardsService.getBadges().then((b) => setState(() => _badges = b));
      _isLoaded = true;
    });
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setInt('avatarIndex', _selectedAvatar);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(AppLocalizations.of(context)!.profile + ' saved!')),
    );
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
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(loc.profile,
              style: useDyslexiaFont
                  ? GoogleFonts.lexend(fontSize: fontSizeProvider.fontSize + 4)
                  : Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: fontSizeProvider.fontSize + 4)),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text('$_coins',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber.shade700)),
                      const SizedBox(width: 16),
                      Icon(Icons.star, color: Colors.yellow.shade700),
                      const SizedBox(width: 4),
                      Text('$_stars',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Badges:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: _badges.isEmpty
                        ? [Text('No badges yet')]
                        : _badges.map((b) => Chip(label: Text(b))).toList(),
                  ),
                ],
              ),
            ),
          ),
          AvatarSelector(
            selectedIndex: _selectedAvatar,
            onAvatarSelected: (index) {
              setState(() {
                _selectedAvatar = index;
              });
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: loc.profile,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.done,
            maxLength: 16,
            style: TextStyle(fontSize: fontSizeProvider.fontSize),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveProfile,
            child: Text('Save',
                style: TextStyle(fontSize: fontSizeProvider.fontSize)),
          ),
        ],
      ),
    );
  }
}
