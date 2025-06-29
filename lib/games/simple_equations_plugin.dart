import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'simple_equations_game.dart';

/// Plugin for SimpleEquationsGame that registers itself with the GameRegistry
class SimpleEquationsPlugin implements GamePlugin {
  static const String _gameId = 'simple-equations';
  static const String _title = 'Simple Equations';
  static const String _description = 'Solve equations with variables';
  static const IconData _icon = Icons.functions;

  /// Register this plugin with the GameRegistry
  static void register() {
    final metadata = GameMetadata(
      id: _gameId,
      title: _title,
      description: _description,
      icon: _icon,
      difficultyLevels: 5,
      tags: ['equations', 'algebra', 'variables'],
      version: '1.0.0',
    );

    final plugin = SimpleEquationsPlugin();
    GameRegistry.registerGame(_gameId, plugin, metadata);
  }

  @override
  MiniGame create() {
    return SimpleEquationsGame();
  }

  @override
  MiniGame? createWithDatabase(GameDataService gameDataService) {
    return SimpleEquationsGame.withDatabase(gameDataService);
  }
} 