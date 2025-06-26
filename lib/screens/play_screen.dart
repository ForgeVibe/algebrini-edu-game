import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            loc.play,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecursiveSequencesGameScreen()),
              );
            },
            child: const Text('Recursive Sequences'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 64),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SimpleEquationsGameScreen()),
              );
            },
            child: const Text('Simple Equations'),
          ),
        ],
      ),
    );
  }
}

class RecursiveSequencesGameScreen extends StatefulWidget {
  const RecursiveSequencesGameScreen({super.key});

  @override
  State<RecursiveSequencesGameScreen> createState() => _RecursiveSequencesGameScreenState();
}

class _RecursiveSequencesGameScreenState extends State<RecursiveSequencesGameScreen> {
  final List<List<int>> _sequences = [
    [1, 1, 2, 3, 5], // Fibonacci
    [2, 4, 6, 8, 10], // Arithmetic
    [3, 6, 12, 24, 48], // Geometric
  ];
  late List<int> _currentSequence;
  late int _answer;
  int _currentIndex = 0;
  String _feedback = '';
  bool _showHint = false;
  bool _showTutorial = true;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSequence();
  }

  void _loadSequence() {
    setState(() {
      _currentSequence = _sequences[_currentIndex % _sequences.length];
      if (_currentIndex % _sequences.length == 0) {
        // Fibonacci
        _answer = _currentSequence[_currentSequence.length - 2] + _currentSequence[_currentSequence.length - 1];
      } else if (_currentIndex % _sequences.length == 1) {
        // Arithmetic
        _answer = _currentSequence.last + 2;
      } else {
        // Geometric
        _answer = _currentSequence.last * 2;
      }
      _controller.clear();
      _feedback = '';
      _showHint = false;
    });
  }

  void _checkAnswer() {
    if (_controller.text.trim() == _answer.toString()) {
      setState(() {
        _feedback = 'Correct!';
        _currentIndex++;
      });
      Future.delayed(const Duration(seconds: 1), () {
        _loadSequence();
      });
    } else {
      setState(() {
        _feedback = 'Try again!';
      });
    }
  }

  void _showGameHint() {
    setState(() {
      _showHint = true;
    });
  }

  void _dismissTutorial() {
    setState(() {
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recursive Sequences')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Complete the sequence:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ..._currentSequence.map((n) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('$n', style: const TextStyle(fontSize: 24)),
                        )),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
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
                  Text(_feedback, style: TextStyle(color: _feedback == 'Correct!' ? Colors.green : Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showGameHint,
                  child: const Text('Hint'),
                ),
                if (_showHint)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _currentIndex % _sequences.length == 0
                          ? 'Each number is the sum of the previous two.'
                          : _currentIndex % _sequences.length == 1
                              ? 'Each number increases by 2.'
                              : 'Each number is multiplied by 2.',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          if (_showTutorial)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('How to Play', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('Look at the sequence and find the pattern. Enter the next number in the sequence.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _dismissTutorial,
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SimpleEquationsGameScreen extends StatefulWidget {
  const SimpleEquationsGameScreen({super.key});

  @override
  State<SimpleEquationsGameScreen> createState() => _SimpleEquationsGameScreenState();
}

class _SimpleEquationsGameScreenState extends State<SimpleEquationsGameScreen> {
  final List<Map<String, dynamic>> _equations = [
    {'question': 'x + 3 = 7', 'answer': 4},
    {'question': '2x = 10', 'answer': 5},
    {'question': 'x - 5 = 2', 'answer': 7},
    {'question': '3x = 9', 'answer': 3},
    {'question': 'x / 2 = 6', 'answer': 12},
  ];
  int _currentIndex = 0;
  String _feedback = '';
  bool _showHint = false;
  bool _showTutorial = true;
  final TextEditingController _controller = TextEditingController();

  void _checkAnswer() {
    if (_controller.text.trim() == _equations[_currentIndex]['answer'].toString()) {
      setState(() {
        _feedback = 'Correct!';
        _currentIndex = (_currentIndex + 1) % _equations.length;
      });
      _controller.clear();
    } else {
      setState(() {
        _feedback = 'Try again!';
      });
    }
  }

  void _showGameHint() {
    setState(() {
      _showHint = true;
    });
  }

  void _dismissTutorial() {
    setState(() {
      _showTutorial = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Equations')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Solve for x:', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text(_equations[_currentIndex]['question'], style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'x = ?',
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
                  Text(_feedback, style: TextStyle(color: _feedback == 'Correct!' ? Colors.green : Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showGameHint,
                  child: const Text('Hint'),
                ),
                if (_showHint)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Isolate x by reversing the operation. For example, if x + 3 = 7, then x = 7 - 3.',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
          if (_showTutorial)
            Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('How to Play', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text('Solve the equation for x and enter your answer.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _dismissTutorial,
                          child: const Text('Got it!'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 