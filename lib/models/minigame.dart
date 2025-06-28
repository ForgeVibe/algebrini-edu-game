import 'package:flutter/material.dart';

/// A class to hold the data for a single challenge in a mini-game.
class GameChallenge {
  final String question;
  final Map<String, dynamic>? data;

  GameChallenge({required this.question, this.data});
}

/// An abstract class representing the contract for any mini-game.
///
/// Each mini-game will implement this class to provide its specific logic
/// and content, allowing the UI to remain generic.
abstract class MiniGame {
  /// The title of the game, used for display in menus.
  String get title;

  /// A unique identifier for the game.
  String get id;

  /// The icon to display for the game in menus.
  IconData get icon;

  /// A brief description of how to play the game.
  String get description;

  /// Generates and returns the current challenge for the player.
  GameChallenge getChallenge();

  /// Checks the player's answer and returns true if correct.
  bool checkAnswer(String answer);

  /// Proceeds to the next challenge or level.
  void next();

  /// Returns a hint for the current challenge.
  String getHint();

  /// Resets the game to its initial state.
  void reset();
}
