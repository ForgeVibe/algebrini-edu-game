import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const String _eventsKey = 'analyticsEvents';

  static Future<void> logEvent(String type, {Map<String, dynamic>? details}) async {
    final prefs = await SharedPreferences.getInstance();
    final events = await getEvents();
    final event = {
      'timestamp': DateTime.now().toIso8601String(),
      'type': type,
      'details': details ?? {},
    };
    events.add(event);
    await prefs.setString(_eventsKey, jsonEncode(events));
  }

  static Future<List<Map<String, dynamic>>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsStr = prefs.getString(_eventsKey);
    if (eventsStr == null || eventsStr.isEmpty) return [];
    final List<dynamic> decoded = jsonDecode(eventsStr);
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> clearEvents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_eventsKey);
  }

  static Future<String> exportAsCSV() async {
    final events = await getEvents();
    if (events.isEmpty) return '';
    final headers = ['timestamp', 'type', 'details'];
    final rows = [headers.join(',')];
    for (final e in events) {
      rows.add('${e['timestamp']},${e['type']},${jsonEncode(e['details'])}');
    }
    return rows.join('\n');
  }

  static Future<String> exportAsJSON() async {
    final events = await getEvents();
    return jsonEncode(events);
  }
} 