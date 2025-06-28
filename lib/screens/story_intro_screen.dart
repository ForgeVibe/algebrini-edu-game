import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryIntroScreen extends StatefulWidget {
  final VoidCallback? onComplete;
  const StoryIntroScreen({Key? key, this.onComplete}) : super(key: key);

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> {
  int _currentPage = 0;
  int? _selectedAvatar;
  bool _isLoading = false;

  final List<String> _storyPages = [
    'Welcome to Algebrini, a magical world where numbers, puzzles, and adventure await!\n\nYou are about to embark on a journey through enchanted lands, solve mysteries, and unlock your math powers.',
    'Meet the Guardians of Math!\n\nChoose your magical companion to guide you on your quest. Each character has a unique personality and style. Who will you be?',
  ];

  final List<Map<String, dynamic>> _avatars = [
    {'name': 'Nova', 'asset': 'assets/avatars/nova.png'},
    {'name': 'Sage', 'asset': 'assets/avatars/sage.png'},
    {'name': 'Pixel', 'asset': 'assets/avatars/pixel.png'},
    {'name': 'Luna', 'asset': 'assets/avatars/luna.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _currentPage == 0 ? _buildStoryPage() : _buildAvatarSelection(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        setState(() => _currentPage--);
                      },
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleNext,
                    child: Text(_currentPage == _storyPages.length - 1 ? 'Start Adventure!' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.deepPurple),
          const SizedBox(height: 24),
          Text(
            _storyPages[0],
            style: GoogleFonts.lexend(fontSize: 22, color: Colors.deepPurple[900]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSelection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _storyPages[1],
          style: GoogleFonts.lexend(fontSize: 20, color: Colors.deepPurple[900]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 24,
          runSpacing: 16,
          children: List.generate(_avatars.length, (i) {
            final avatar = _avatars[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = i),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _selectedAvatar == i ? Colors.amber : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        avatar['asset'],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.person, size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    avatar['name'],
                    style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
        ),
        if (_selectedAvatar == null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text('Tap an avatar to select', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Future<void> _handleNext() async {
    if (_currentPage == 0) {
      setState(() => _currentPage++);
    } else {
      if (_selectedAvatar == null) return;
      setState(() => _isLoading = true);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selectedAvatar', _selectedAvatar!);
      await prefs.setBool('storyIntroSeen', true);
      setState(() => _isLoading = false);
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }
} 