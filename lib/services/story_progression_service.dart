import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StoryProgressionService {
  static const String _currentChapterKey = 'currentChapter';
  static const String _unlockedChaptersKey = 'unlockedChapters';
  static const String _storyProgressKey = 'storyProgress';
  static const String _characterProgressKey = 'characterProgress';
  static const String _worldMapUnlocksKey = 'worldMapUnlocks';

  // Story chapters with their requirements and content
  static const Map<String, Map<String, dynamic>> _chapters = {
    'chapter_1': {
      'title': 'The Awakening',
      'subtitle': 'Discovering the Magic of Numbers',
      'description':
          'Welcome to Algebrini! Your journey begins in the mystical realm where numbers come alive.',
      'requirements': {'type': 'none'},
      'realm': 'crystal_forest',
      'games': ['recursive-sequences'],
      'levels': [1, 2],
      'storyCutscene': 'chapter_1_intro',
      'rewards': {'stars': 10, 'badge': 'first_steps'},
    },
    'chapter_2': {
      'title': 'The Pattern Seekers',
      'subtitle': 'Unlocking the Secrets of Sequences',
      'description':
          'Deep in the Crystal Forest, ancient patterns reveal themselves to those who look carefully.',
      'requirements': {'type': 'chapter_completion', 'chapter': 'chapter_1'},
      'realm': 'crystal_forest',
      'games': ['recursive-sequences'],
      'levels': [3, 4, 5],
      'storyCutscene': 'chapter_2_intro',
      'rewards': {'stars': 15, 'badge': 'pattern_master'},
    },
    'chapter_3': {
      'title': 'The Equation Valley',
      'subtitle': 'Solving the Mysteries of Variables',
      'description':
          'Beyond the forest lies the Equation Valley, where unknown values hide in plain sight.',
      'requirements': {
        'type': 'game_completion',
        'game': 'recursive-sequences',
        'levels': 3
      },
      'realm': 'equation_valley',
      'games': ['simple-equations'],
      'levels': [1, 2, 3],
      'storyCutscene': 'chapter_3_intro',
      'rewards': {'stars': 20, 'badge': 'equation_solver'},
    },
    'chapter_4': {
      'title': 'The Factorization Caves',
      'subtitle': 'Breaking Down the Building Blocks',
      'description':
          'In the depths of the Factorization Caves, numbers break apart to reveal their secrets.',
      'requirements': {
        'type': 'game_completion',
        'game': 'simple-equations',
        'levels': 2
      },
      'realm': 'factorization_caves',
      'games': ['factorization-fun'],
      'levels': [1, 2, 3],
      'storyCutscene': 'chapter_4_intro',
      'rewards': {'stars': 25, 'badge': 'factor_finder'},
    },
    'chapter_5': {
      'title': 'The Grand Convergence',
      'subtitle': 'Mastering All Mathematical Arts',
      'description':
          'At the heart of Algebrini, all mathematical paths converge in the ultimate challenge.',
      'requirements': {
        'type': 'all_games_completion',
        'games': [
          'recursive-sequences',
          'simple-equations',
          'factorization-fun'
        ]
      },
      'realm': 'convergence_tower',
      'games': ['recursive-sequences', 'simple-equations', 'factorization-fun'],
      'levels': [4, 5],
      'storyCutscene': 'chapter_5_intro',
      'rewards': {'stars': 50, 'badge': 'algebrini_master'},
    },
  };

  // World realms with their descriptions and visual themes
  static const Map<String, Map<String, dynamic>> _realms = {
    'crystal_forest': {
      'name': 'Crystal Forest',
      'description':
          'A mystical forest where crystal formations follow mathematical patterns',
      'color': 'green',
      'icon': 'forest',
      'background': 'assets/backgrounds/crystal_forest.png',
    },
    'equation_valley': {
      'name': 'Equation Valley',
      'description':
          'A valley where equations float in the air like ancient runes',
      'color': 'blue',
      'icon': 'valley',
      'background': 'assets/backgrounds/equation_valley.png',
    },
    'factorization_caves': {
      'name': 'Factorization Caves',
      'description':
          'Deep caves where numbers break apart into their prime factors',
      'color': 'purple',
      'icon': 'cave',
      'background': 'assets/backgrounds/factorization_caves.png',
    },
    'convergence_tower': {
      'name': 'Convergence Tower',
      'description':
          'A towering structure where all mathematical knowledge converges',
      'color': 'gold',
      'icon': 'tower',
      'background': 'assets/backgrounds/convergence_tower.png',
    },
  };

  // Story cutscenes content
  static const Map<String, Map<String, dynamic>> _cutscenes = {
    'chapter_1_intro': {
      'title': 'Welcome to Algebrini',
      'content': [
        'Welcome, young mathematician! You have been chosen to explore the magical world of Algebrini.',
        'Here, numbers are not just symbols on a page - they are living, breathing entities with stories to tell.',
        'Your journey begins in the Crystal Forest, where patterns emerge from the very air around you.',
        'Are you ready to discover the secrets that lie within?',
      ],
      'character': 'narrator',
      'background': 'crystal_forest',
    },
    'chapter_2_intro': {
      'title': 'The Pattern Seekers',
      'content': [
        'You have proven yourself worthy of the Crystal Forest\'s secrets!',
        'But there is more to discover. The ancient patterns grow more complex, revealing deeper mathematical truths.',
        'Each sequence you solve unlocks a piece of the forest\'s ancient wisdom.',
        'Continue your quest, pattern seeker!',
      ],
      'character': 'narrator',
      'background': 'crystal_forest',
    },
    'chapter_3_intro': {
      'title': 'Beyond the Forest',
      'content': [
        'Your mastery of patterns has opened the path to the Equation Valley!',
        'Here, unknown values hide in plain sight, waiting to be discovered.',
        'Variables are not just letters - they are the keys to unlocking mathematical mysteries.',
        'Prepare to solve equations that have puzzled scholars for generations!',
      ],
      'character': 'narrator',
      'background': 'equation_valley',
    },
    'chapter_4_intro': {
      'title': 'The Factorization Caves',
      'content': [
        'Your journey leads you to the Factorization Caves, where numbers reveal their true nature.',
        'Every number is made up of smaller building blocks - prime factors.',
        'By breaking numbers apart, you will understand how they are constructed.',
        'Enter the caves and discover the building blocks of mathematics!',
      ],
      'character': 'narrator',
      'background': 'factorization_caves',
    },
    'chapter_5_intro': {
      'title': 'The Grand Convergence',
      'content': [
        'You have mastered the individual arts of mathematics!',
        'Now, at the Convergence Tower, all your knowledge will be tested.',
        'Patterns, equations, and factorization - they all work together.',
        'This is your final challenge. Are you ready to become a true master of Algebrini?',
      ],
      'character': 'narrator',
      'background': 'convergence_tower',
    },
  };

  // Get current chapter
  static Future<String> getCurrentChapter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentChapterKey) ?? 'chapter_1';
  }

  // Get unlocked chapters
  static Future<List<String>> getUnlockedChapters() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedStr = prefs.getString(_unlockedChaptersKey) ?? 'chapter_1';
    return unlockedStr.split(',');
  }

  // Check if a chapter is unlocked
  static Future<bool> isChapterUnlocked(String chapterId) async {
    final unlockedChapters = await getUnlockedChapters();
    return unlockedChapters.contains(chapterId);
  }

  // Get chapter details
  static Map<String, dynamic> getChapterDetails(String chapterId) {
    return _chapters[chapterId] ?? {};
  }

  // Get all chapter details
  static Map<String, Map<String, dynamic>> getAllChapterDetails() {
    return Map.from(_chapters);
  }

  // Get realm details
  static Map<String, dynamic> getRealmDetails(String realmId) {
    return _realms[realmId] ?? {};
  }

  // Get all realm details
  static Map<String, Map<String, dynamic>> getAllRealmDetails() {
    return Map.from(_realms);
  }

  // Get cutscene content
  static Map<String, dynamic> getCutsceneContent(String cutsceneId) {
    return _cutscenes[cutsceneId] ?? {};
  }

  // Record chapter completion
  static Future<void> completeChapter(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();

    // Update current chapter
    await prefs.setString(_currentChapterKey, chapterId);

    // Add to unlocked chapters if not already there
    final unlockedChapters = await getUnlockedChapters();
    if (!unlockedChapters.contains(chapterId)) {
      unlockedChapters.add(chapterId);
      await prefs.setString(_unlockedChaptersKey, unlockedChapters.join(','));
    }

    // Record story progress
    final progressStr = prefs.getString(_storyProgressKey) ?? '{}';
    final progress = Map<String, dynamic>.from(jsonDecode(progressStr));
    progress[chapterId] = {
      'completed': true,
      'completedAt': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_storyProgressKey, jsonEncode(progress));

    // Check for new chapter unlocks
    await _checkForNewChapterUnlocks();
  }

  // Get story progress
  static Future<Map<String, dynamic>> getStoryProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressStr = prefs.getString(_storyProgressKey) ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(progressStr));
  }

  // Get character progress
  static Future<Map<String, dynamic>> getCharacterProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressStr = prefs.getString(_characterProgressKey) ?? '{}';
    return Map<String, dynamic>.from(jsonDecode(progressStr));
  }

  // Update character progress
  static Future<void> updateCharacterProgress(
      String characterId, Map<String, dynamic> progress) async {
    final prefs = await SharedPreferences.getInstance();
    final currentProgressStr = prefs.getString(_characterProgressKey) ?? '{}';
    final currentProgress =
        Map<String, dynamic>.from(jsonDecode(currentProgressStr));
    currentProgress[characterId] = progress;
    await prefs.setString(_characterProgressKey, jsonEncode(currentProgress));
  }

  // Get available chapters for a player
  static Future<List<String>> getAvailableChapters() async {
    final unlockedChapters = await getUnlockedChapters();
    final available = <String>[];

    for (final chapterId in _chapters.keys) {
      if (await _canAccessChapter(chapterId)) {
        available.add(chapterId);
      }
    }

    return available;
  }

  // Check if player can access a chapter
  static Future<bool> _canAccessChapter(String chapterId) async {
    final chapter = _chapters[chapterId];
    if (chapter == null) return false;

    final requirements = chapter['requirements'];
    if (requirements == null) return true;

    switch (requirements['type']) {
      case 'none':
        return true;
      case 'chapter_completion':
        final requiredChapter = requirements['chapter'] as String;
        return await isChapterUnlocked(requiredChapter);
      case 'game_completion':
        final game = requirements['game'] as String;
        final levels = requirements['levels'] as int;
        return await _hasCompletedGameLevels(game, levels);
      case 'all_games_completion':
        final games = requirements['games'] as List<String>;
        return await _hasCompletedAllGames(games);
      default:
        return false;
    }
  }

  // Check if player has completed required levels for a game
  static Future<bool> _hasCompletedGameLevels(String gameId, int levels) async {
    // This would integrate with LevelProgressionService
    // For now, return true as placeholder
    return true;
  }

  // Check if player has completed all required games
  static Future<bool> _hasCompletedAllGames(List<String> games) async {
    // This would integrate with LevelProgressionService
    // For now, return true as placeholder
    return true;
  }

  // Check for new chapter unlocks
  static Future<void> _checkForNewChapterUnlocks() async {
    final unlockedChapters = await getUnlockedChapters();
    final newUnlocks = <String>[];

    for (final chapterId in _chapters.keys) {
      if (!unlockedChapters.contains(chapterId) &&
          await _canAccessChapter(chapterId)) {
        newUnlocks.add(chapterId);
      }
    }

    if (newUnlocks.isNotEmpty) {
      final allUnlocked = [...unlockedChapters, ...newUnlocks];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unlockedChaptersKey, allUnlocked.join(','));
    }
  }

  // Reset story progress
  static Future<void> resetStoryProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentChapterKey);
    await prefs.remove(_unlockedChaptersKey);
    await prefs.remove(_storyProgressKey);
    await prefs.remove(_characterProgressKey);
    await prefs.remove(_worldMapUnlocksKey);
  }

  // Get next chapter to unlock
  static Future<String?> getNextChapterToUnlock() async {
    final unlockedChapters = await getUnlockedChapters();

    for (final chapterId in _chapters.keys) {
      if (!unlockedChapters.contains(chapterId) &&
          await _canAccessChapter(chapterId)) {
        return chapterId;
      }
    }

    return null;
  }

  // Get chapters by realm
  static List<String> getChaptersByRealm(String realmId) {
    return _chapters.entries
        .where((entry) => entry.value['realm'] == realmId)
        .map((entry) => entry.key)
        .toList();
  }

  // Get available realms
  static Future<List<String>> getAvailableRealms() async {
    final unlockedChapters = await getUnlockedChapters();
    final realms = <String>{};

    for (final chapterId in unlockedChapters) {
      final chapter = _chapters[chapterId];
      if (chapter != null) {
        realms.add(chapter['realm'] as String);
      }
    }

    return realms.toList();
  }
}
