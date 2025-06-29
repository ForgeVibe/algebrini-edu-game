/// Central game loader that imports all game plugins
/// 
/// This file serves as a single point of entry to load all available games.
/// When this file is imported, all game plugins will automatically register
/// themselves with the GameRegistry.
/// 
/// To add a new game:
/// 1. Create a new game plugin (e.g., new_game_plugin.dart)
/// 2. Add an import statement below
/// 3. Call the register method in the loadAllGames function

// Import all game plugins to ensure they register themselves
import 'recursive_sequences_plugin.dart';
import 'simple_equations_plugin.dart';
import 'factorization_plugin.dart';

/// Initialize all games by importing this file
/// This ensures all game plugins are registered with the GameRegistry
class GameLoader {
  /// Load all games (this is called automatically when this file is imported)
  static void loadAllGames() {
    // Register all game plugins
    RecursiveSequencesPlugin.register();
    SimpleEquationsPlugin.register();
    FactorizationPlugin.register();
    
    print('GameLoader: All game plugins loaded and registered');
  }
} 