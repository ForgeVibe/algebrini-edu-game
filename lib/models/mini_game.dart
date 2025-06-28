import 'game_level.dart';

class MiniGame {
  final String id;
  final String name;
  final String description;
  final List<GameLevel> levels;

  MiniGame({
    required this.id,
    required this.name,
    required this.description,
    required this.levels,
  });
}
