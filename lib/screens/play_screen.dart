import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/game_registry.dart';
import 'package:algebrini_edu_game/screens/game_screen.dart';
import 'level_selection_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  late final List<MiniGame> _games;

  @override
  void initState() {
    super.initState();
    _games = GameRegistry().getGames();
  }

  void _startGame(MiniGame game) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LevelSelectionScreen(
          gameId: game.id,
          chapterTitle: game.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.play),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(game.icon,
                  size: 40, color: Theme.of(context).primaryColor),
              title: Text(game.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(game.description),
              trailing: const Icon(Icons.play_circle_fill),
              onTap: () {
                _startGame(game);
              },
            ),
          );
        },
      ),
    );
  }
}
