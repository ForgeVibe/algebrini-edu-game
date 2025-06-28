import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();

  static Future<void> speak(String text) async {
    await _tts.setLanguage('en-US'); // TODO: Make dynamic based on app language
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  // The isSpeaking getter is not supported on all platforms (e.g., web), so we stub it out.
  static Future<bool> isSpeaking() async {
    return false;
  }
}
