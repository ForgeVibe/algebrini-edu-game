import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'recursive_sequences_game.dart';

/// Plugin for RecursiveSequencesGame that registers itself with the GameRegistry
class RecursiveSequencesPlugin implements GamePlugin {
  static const String _gameId = 'recursive-sequences';
  static const String _title = 'Recursive Sequences';
  static const String _description = 'Discover patterns in number sequences';
  static const IconData _icon = Icons.trending_up;

  /// Register this plugin with the GameRegistry
  static void register() {
    final metadata = GameMetadata(
      id: _gameId,
      title: _title,
      description: _description,
      icon: _icon,
      difficultyLevels: 5,
      tags: ['patterns', 'sequences', 'mathematics'],
      version: '1.0.0',
    );

    final plugin = RecursiveSequencesPlugin();
    GameRegistry.registerGame(_gameId, plugin, metadata);
  }

  @override
  MiniGame create() {
    return RecursiveSequencesGame();
  }

  @override
  MiniGame? createWithDatabase(GameDataService gameDataService) {
    return RecursiveSequencesGame.withDatabase(gameDataService);
  }
} 