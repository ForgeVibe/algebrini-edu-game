import 'package:shared_preferences/shared_preferences.dart';

class RewardsService {
  static const String _coinsKey = 'coins';
  static const String _starsKey = 'stars';
  static const String _badgesKey = 'badges'; // Comma-separated badge IDs

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinsKey) ?? 0;
  }

  static Future<int> getStars() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_starsKey) ?? 0;
  }

  static Future<List<String>> getBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final badgesStr = prefs.getString(_badgesKey) ?? '';
    return badgesStr.isEmpty ? [] : badgesStr.split(',');
  }

  static Future<void> addCoins(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinsKey) ?? 0;
    await prefs.setInt(_coinsKey, current + amount);
  }

  static Future<void> addStars(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_starsKey) ?? 0;
    await prefs.setInt(_starsKey, current + amount);
  }

  static Future<void> addBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final badges = await getBadges();
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await prefs.setString(_badgesKey, badges.join(','));
    }
  }

  static Future<void> resetRewards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_coinsKey);
    await prefs.remove(_starsKey);
    await prefs.remove(_badgesKey);
  }
}
