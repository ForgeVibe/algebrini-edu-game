import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/story_progression_service.dart';

class StoryCutsceneScreen extends StatefulWidget {
  final String cutsceneId;

  const StoryCutsceneScreen({
    Key? key,
    required this.cutsceneId,
  }) : super(key: key);

  @override
  State<StoryCutsceneScreen> createState() => _StoryCutsceneScreenState();
}

class _StoryCutsceneScreenState extends State<StoryCutsceneScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _textController;
  late AnimationController _characterController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _characterAnimation;

  int _currentTextIndex = 0;
  bool _isTextComplete = false;
  bool _showContinueButton = false;

  Map<String, dynamic> _cutsceneData = {};
  List<String> _textContent = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadCutsceneData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _textController.dispose();
    _characterController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _characterController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _characterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _characterController,
      curve: Curves.elasticOut,
    ));

    _fadeController.forward();
  }

  void _loadCutsceneData() {
    _cutsceneData =
        StoryProgressionService.getCutsceneContent(widget.cutsceneId);
    _textContent = List<String>.from(_cutsceneData['content'] ?? []);

    if (_textContent.isNotEmpty) {
      _startTextAnimation();
    }
  }

  void _startTextAnimation() {
    _textController.forward().then((_) {
      setState(() {
        _isTextComplete = true;
        _showContinueButton = true;
      });
    });
  }

  void _nextText() {
    if (_currentTextIndex < _textContent.length - 1) {
      setState(() {
        _currentTextIndex++;
        _isTextComplete = false;
        _showContinueButton = false;
      });

      _textController.reset();
      _startTextAnimation();
    } else {
      _completeCutscene();
    }
  }

  void _completeCutscene() {
    Navigator.of(context).pop(true); // Return true to continue to game
  }

  void _skipCutscene() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip Cutscene?'),
        content:
            const Text('Are you sure you want to skip this story sequence?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _completeCutscene();
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundDecoration(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildCutsceneContent(),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration() {
    final background = _cutsceneData['background'] as String?;

    if (background != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(background),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      );
    }

    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1a237e),
          Color(0xFF0d47a1),
          Color(0xFF01579b),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _skipCutscene,
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
          const Spacer(),
          Text(
            _cutsceneData['title'] as String? ?? 'Story',
            style: GoogleFonts.lexend(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }

  Widget _buildCutsceneContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Character/Icon
            _buildCharacterSection(),
            const SizedBox(height: 40),

            // Story text
            _buildStoryText(),
            const SizedBox(height: 40),

            // Continue button
            if (_showContinueButton) _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSection() {
    return ScaleTransition(
      scale: _characterAnimation,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
        ),
        child: Icon(
          _getCharacterIcon(_cutsceneData['character'] as String?),
          size: 60,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStoryText() {
    if (_textContent.isEmpty) {
      return const SizedBox.shrink();
    }

    final currentText = _textContent[_currentTextIndex];

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _textAnimation,
            builder: (context, child) {
              final textLength =
                  (currentText.length * _textAnimation.value).round();
              final displayText = currentText.substring(0, textLength);

              return Text(
                displayText,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  color: Colors.white,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          if (_isTextComplete) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentTextIndex + 1} / ${_textContent.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return FadeTransition(
      opacity: _textAnimation,
      child: ElevatedButton(
        onPressed: _nextText,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _currentTextIndex < _textContent.length - 1
              ? 'Continue'
              : 'Begin Adventure!',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _skipCutscene,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          if (_textContent.isNotEmpty)
            Text(
              'Tap to continue',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          const SizedBox(width: 60), // Balance the skip button
        ],
      ),
    );
  }

  IconData _getCharacterIcon(String? character) {
    switch (character) {
      case 'narrator':
        return Icons.auto_awesome;
      case 'nova':
        return Icons.star;
      case 'sage':
        return Icons.psychology;
      case 'pixel':
        return Icons.computer;
      case 'luna':
        return Icons.nightlight;
      default:
        return Icons.person;
    }
  }
}
