import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/story_progression_service.dart';
import '../services/level_progression_service.dart';
import 'story_cutscene_screen.dart';
import 'level_selection_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({Key? key}) : super(key: key);

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen> with TickerProviderStateMixin {
  late AnimationController _mapController;
  late AnimationController _realmController;
  late Animation<double> _mapAnimation;
  late Animation<double> _realmAnimation;
  
  Map<String, dynamic> _storyProgress = {};
  List<String> _unlockedChapters = [];
  List<String> _availableRealms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _realmController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _mapAnimation = CurvedAnimation(
      parent: _mapController,
      curve: Curves.easeInOut,
    );
    _realmAnimation = CurvedAnimation(
      parent: _realmController,
      curve: Curves.elasticOut,
    );
    
    _loadWorldData();
    _mapController.forward();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _realmController.dispose();
    super.dispose();
  }

  Future<void> _loadWorldData() async {
    final storyProgress = await StoryProgressionService.getStoryProgress();
    final unlockedChapters = await StoryProgressionService.getUnlockedChapters();
    final availableRealms = await StoryProgressionService.getAvailableRealms();
    
    setState(() {
      _storyProgress = storyProgress;
      _unlockedChapters = unlockedChapters;
      _availableRealms = availableRealms;
      _isLoading = false;
    });
    
    _realmController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a237e),
              Color(0xFF0d47a1),
              Color(0xFF01579b),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading 
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : _buildWorldMap(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'World of Algebrini',
              style: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: _showWorldInfo,
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildWorldMap() {
    return FadeTransition(
      opacity: _mapAnimation,
      child: Stack(
        children: [
          // Background world map
          _buildBackgroundMap(),
          
          // Realm locations
          ..._buildRealmLocations(),
          
          // Floating particles effect
          _buildParticleEffect(),
        ],
      ),
    );
  }

  Widget _buildBackgroundMap() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4a148c),
                Color(0xFF311b92),
                Color(0xFF1a237e),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRealmLocations() {
    final allRealms = StoryProgressionService.getAllRealmDetails();
    final widgets = <Widget>[];
    
    // Define realm positions on the map
    const realmPositions = {
      'crystal_forest': {'x': 0.2, 'y': 0.3},
      'equation_valley': {'x': 0.8, 'y': 0.4},
      'factorization_caves': {'x': 0.5, 'y': 0.7},
      'convergence_tower': {'x': 0.5, 'y': 0.2},
    };
    
    for (final entry in allRealms.entries) {
      final realmId = entry.key;
      final realm = entry.value;
      final position = realmPositions[realmId];
      
      if (position != null) {
        final isAvailable = _availableRealms.contains(realmId);
        final isUnlocked = _unlockedChapters.any((chapter) {
          final chapterDetails = StoryProgressionService.getChapterDetails(chapter);
          return chapterDetails['realm'] == realmId;
        });
        
        widgets.add(
          Positioned(
            left: position['x']! * (MediaQuery.of(context).size.width - 64),
            top: position['y']! * (MediaQuery.of(context).size.height - 200),
            child: _buildRealmLocation(realmId, realm, isAvailable, isUnlocked),
          ),
        );
      }
    }
    
    return widgets;
  }

  Widget _buildRealmLocation(String realmId, Map<String, dynamic> realm, bool isAvailable, bool isUnlocked) {
    final color = _getRealmColor(realm['color'] as String);
    final isActive = isAvailable && isUnlocked;
    
    return ScaleTransition(
      scale: _realmAnimation,
      child: GestureDetector(
        onTap: isActive ? () => _onRealmTapped(realmId) : null,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.grey.withOpacity(0.3),
            border: Border.all(
              color: isActive ? Colors.white : Colors.grey.withOpacity(0.5),
              width: isActive ? 3 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withOpacity(0.6),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Icon(
            _getRealmIcon(realm['icon'] as String),
            color: isActive ? Colors.white : Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildParticleEffect() {
    return CustomPaint(
      painter: ParticlePainter(),
      size: Size.infinite,
    );
  }

  Color _getRealmColor(String colorName) {
    switch (colorName) {
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      case 'gold': return Colors.amber;
      default: return Colors.grey;
    }
  }

  IconData _getRealmIcon(String iconName) {
    switch (iconName) {
      case 'forest': return Icons.forest;
      case 'valley': return Icons.landscape;
      case 'cave': return Icons.landscape;
      case 'tower': return Icons.castle;
      default: return Icons.location_on;
    }
  }

  void _onRealmTapped(String realmId) async {
    final realm = StoryProgressionService.getRealmDetails(realmId);
    final chapters = StoryProgressionService.getChaptersByRealm(realmId);
    final availableChapters = chapters.where((chapter) => 
        _unlockedChapters.contains(chapter)).toList();
    
    if (availableChapters.isEmpty) {
      _showRealmLockedDialog(realm);
      return;
    }
    
    // Show realm selection dialog
    final selectedChapter = await _showRealmSelectionDialog(realm, availableChapters);
    if (selectedChapter != null) {
      _navigateToChapter(selectedChapter);
    }
  }

  void _showRealmLockedDialog(Map<String, dynamic> realm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(realm['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'This realm is not yet unlocked.\nComplete previous chapters to access it.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRealmSelectionDialog(Map<String, dynamic> realm, List<String> availableChapters) async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(realm['name'] as String),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              realm['description'] as String,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...availableChapters.map((chapterId) {
              final chapter = StoryProgressionService.getChapterDetails(chapterId);
              return ListTile(
                leading: Icon(Icons.play_circle, color: Colors.blue),
                title: Text(chapter['title'] as String),
                subtitle: Text(chapter['subtitle'] as String),
                onTap: () => Navigator.of(context).pop(chapterId),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _navigateToChapter(String chapterId) async {
    final chapter = StoryProgressionService.getChapterDetails(chapterId);
    final cutsceneId = chapter['storyCutscene'] as String?;
    
    if (cutsceneId != null) {
      // Show story cutscene first
      final shouldContinue = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => StoryCutsceneScreen(cutsceneId: cutsceneId),
        ),
      );
      
      if (shouldContinue == true) {
        // Navigate to level selection
        _navigateToLevelSelection(chapter);
      }
    } else {
      // Navigate directly to level selection
      _navigateToLevelSelection(chapter);
    }
  }

  void _navigateToLevelSelection(Map<String, dynamic> chapter) {
    final games = chapter['games'] as List<String>?;
    if (games != null && games.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LevelSelectionScreen(
            gameId: games.first,
            chapterTitle: chapter['title'] as String,
          ),
        ),
      );
    }
  }

  void _showWorldInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Algebrini'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the magical world of Algebrini!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Explore different realms to discover mathematical concepts\n'
              '• Complete chapters to unlock new areas\n'
              '• Each realm focuses on specific mathematical skills\n'
              '• Follow the story to become a master mathematician!',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 