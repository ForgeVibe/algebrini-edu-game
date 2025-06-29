import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/services/game_data_service.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'factorization_game.dart';

/// Plugin for FactorizationGame that registers itself with the GameRegistry
class FactorizationPlugin implements GamePlugin {
  static const String _gameId = 'factorization-fun';
  static const String _title = 'Factorization Fun';
  static const String _description = 'Break numbers into their factors';
  static const IconData _icon = Icons.calculate;

  /// Register this plugin with the GameRegistry
  static void register() {
    final metadata = GameMetadata(
      id: _gameId,
      title: _title,
      description: _description,
      icon: _icon,
      difficultyLevels: 5,
      tags: ['factors', 'multiplication', 'numbers'],
      version: '1.0.0',
    );

    final plugin = FactorizationPlugin();
    GameRegistry.registerGame(_gameId, plugin, metadata);
  }

  @override
  MiniGame create() {
    return FactorizationGame();
  }

  @override
  MiniGame? createWithDatabase(GameDataService gameDataService) {
    return FactorizationGame.withDatabase(gameDataService);
  }
} 