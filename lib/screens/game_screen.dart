import 'package:flutter/material.dart';
import 'package:algebrini_edu_game/models/minigame.dart';
import 'package:algebrini_edu_game/services/game_stats_service.dart';

/// A generic screen that can host and run any mini-game that implements
/// the [MiniGame] interface.
class GameScreen extends StatefulWidget {
  final MiniGame game;

  const GameScreen({required this.game, super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameChallenge _currentChallenge;
  final TextEditingController _controller = TextEditingController();
  String _feedback = '';
  bool _showHint = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    widget.game.reset();
    _currentChallenge = widget.game.getChallenge();
  }

  Future<void> _checkAnswer() async {
    final isCorrect = widget.game.checkAnswer(_controller.text);

    // Record the answer using the service
    await GameStatsService.recordAnswer(isCorrect, widget.game.id);

    setState(() {
      _isCorrect = isCorrect;
      _feedback = isCorrect ? 'Correct!' : 'Try again!';
    });

    if (isCorrect) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          widget.game.next();
          _currentChallenge = widget.game.getChallenge();
          _controller.clear();
          _feedback = '';
          _showHint = false;
          _isCorrect = false;
        });
      });
    }
  }

  void _showGameHint() {
    setState(() {
      _showHint = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.title)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.game.description,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              _currentChallenge.question,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _checkAnswer(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAnswer,
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            if (_feedback.isNotEmpty)
              Text(
                _feedback,
                style: TextStyle(
                    color: _isCorrect ? Colors.green : Colors.red,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _showGameHint,
              child: const Text('Hint'),
            ),
            if (_showHint)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.game.getHint(),
                  style: const TextStyle(color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
