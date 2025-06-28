import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontSizeProvider extends ChangeNotifier {
  static const String _fontSizeKey = 'fontSize';
  static const String _dyslexiaFontKey = 'dyslexiaFont';
  static const double defaultFontSize = 18.0;
  double _fontSize = defaultFontSize;
  bool _dyslexiaFont = false;

  double get fontSize => _fontSize;
  bool get dyslexiaFont => _dyslexiaFont;

  FontSizeProvider() {
    _loadFontSize();
    _loadDyslexiaFont();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    _fontSize = prefs.getDouble(_fontSizeKey) ?? defaultFontSize;
    notifyListeners();
  }

  Future<void> _loadDyslexiaFont() async {
    final prefs = await SharedPreferences.getInstance();
    _dyslexiaFont = prefs.getBool(_dyslexiaFontKey) ?? false;
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    notifyListeners();
  }

  Future<void> setDyslexiaFont(bool value) async {
    _dyslexiaFont = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dyslexiaFontKey, value);
    notifyListeners();
  }
}
