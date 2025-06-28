import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/level_progression_service.dart';
import '../games/recursive_sequences_game.dart';
import '../games/simple_equations_game.dart';
import '../games/factorization_game.dart';
import 'game_screen.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String gameId;
  final String chapterTitle;
  
  const LevelSelectionScreen({
    Key? key,
    required this.gameId,
    required this.chapterTitle,
  }) : super(key: key);

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  List<int> _availableLevels = [];
  Map<int, bool> _levelCompletionStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevelData();
  }

  Future<void> _loadLevelData() async {
    // For now, use a simple list of levels
    final availableLevels = [1, 2, 3, 4, 5];
    final completionStatus = <int, bool>{};
    
    for (final level in availableLevels) {
      final isCompleted = await LevelProgressionService.isLevelCompleted(
        widget.gameId, 
        level,
      );
      completionStatus[level] = isCompleted;
    }
    
    setState(() {
      _availableLevels = availableLevels;
      _levelCompletionStatus = completionStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chapterTitle,
          style: GoogleFonts.lexend(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _buildLevelGrid(),
      ),
    );
  }

  Widget _buildLevelGrid() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a Level',
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a level to start your mathematical adventure!',
            style: GoogleFonts.lexend(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: _availableLevels.length,
              itemBuilder: (context, index) {
                final level = _availableLevels[index];
                final isCompleted = _levelCompletionStatus[level] ?? false;
                final isUnlocked = _isLevelUnlocked(level);
                
                return _buildLevelCard(level, isCompleted, isUnlocked);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(int level, bool isCompleted, bool isUnlocked) {
    return GestureDetector(
      onTap: isUnlocked ? () => _startLevel(level) : null,
      child: Card(
        elevation: isUnlocked ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: _getLevelCardColor(isCompleted, isUnlocked),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getLevelBorderColor(isCompleted, isUnlocked),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                )
              else if (!isUnlocked)
                Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 32,
                )
              else
                Icon(
                  Icons.play_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              const SizedBox(height: 8),
              Text(
                'Level $level',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getLevelTextColor(isCompleted, isUnlocked),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Normal',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  color: _getLevelTextColor(isCompleted, isUnlocked).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelCardColor(bool isCompleted, bool isUnlocked) {
    if (isCompleted) {
      return Colors.green.withOpacity(0.2);
    } else if (!isUnlocked) {
      return Colors.grey.withOpacity(0.1);
    } else {
      return Colors.white;
    }
  }

  Color _getLevelBorderColor(bool isCompleted, bool isUnlocked) {
    if (isCompleted) {
      return Colors.green;
    } else if (!isUnlocked) {
      return Colors.grey.withOpacity(0.3);
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }

  Color _getLevelTextColor(bool isCompleted, bool isUnlocked) {
    if (isCompleted) {
      return Colors.green.shade700;
    } else if (!isUnlocked) {
      return Colors.grey;
    } else {
      return Colors.black87;
    }
  }

  bool _isLevelUnlocked(int level) {
    // For now, all levels are unlocked
    // In the future, this could check prerequisites
    return true;
  }

  void _startLevel(int level) {
    // Create the appropriate game based on gameId
    final game = _createGame(widget.gameId);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(game: game),
      ),
    ).then((_) {
      // Refresh level completion status when returning from game
      _loadLevelData();
    });
  }

  dynamic _createGame(String gameId) {
    switch (gameId) {
      case 'recursive-sequences':
        return RecursiveSequencesGame();
      case 'simple-equations':
        return SimpleEquationsGame();
      case 'factorization-fun':
        return FactorizationGame();
      default:
        return RecursiveSequencesGame(); // Default fallback
    }
  }
} 