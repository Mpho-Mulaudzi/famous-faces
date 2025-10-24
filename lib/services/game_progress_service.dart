import 'package:shared_preferences/shared_preferences.dart';

class GameProgressService {
  static const _keyPlayedCount = 'played_count';
  static const _keyLastReset = 'last_reset';
  static const _keyLastCategory = 'last_category';
  static const _keyLastIndex = 'last_index';

  static const _keyTopStreak = 'top_streak';
  static const _keyLastScore = 'last_score';



  static const int maxQuestions = 10;
  static const Duration cooldown = Duration(minutes: 5);

  /// Returns true if user can continue playing now
  static Future<bool> canPlayNow() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final lastResetString = prefs.getString(_keyLastReset);
    DateTime? lastReset =
    lastResetString != null ? DateTime.tryParse(lastResetString) : null;

    int count = prefs.getInt(_keyPlayedCount) ?? 0;

    // Reset after cooldown
    if (lastReset == null || now.difference(lastReset) >= cooldown) {
      await prefs.setInt(_keyPlayedCount, 0);
      await prefs.setString(_keyLastReset, now.toIso8601String());
      return true;
    }

    return count < maxQuestions;
  }

  static Future<int> remainingQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_keyPlayedCount) ?? 0;
    return maxQuestions - count;
  }

  static Future<void> incrementPlayCount({
    required String category,
    required int index,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyPlayedCount) ?? 0;
    await prefs.setInt(_keyPlayedCount, current + 1);
    await prefs.setString(_keyLastCategory, category);
    await prefs.setInt(_keyLastIndex, index);
  }
  /// Increments the play count and returns whether the user can still play
  static Future<bool> incrementAndCheckLimit({
    required String category,
    required int index,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // increment count
    int current = prefs.getInt(_keyPlayedCount) ?? 0;
    current++;
    await prefs.setInt(_keyPlayedCount, current);
    await prefs.setString(_keyLastCategory, category);
    await prefs.setInt(_keyLastIndex, index);

    // Check if they’ve exceeded the limit
    return current < maxQuestions;
  }


  static Future<Map<String, dynamic>?> getLastProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final category = prefs.getString(_keyLastCategory);
    final index = prefs.getInt(_keyLastIndex);
    if (category != null && index != null) {
      return {'category': category, 'index': index};
    }
    return null;
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastCategory);
    await prefs.remove(_keyLastIndex);
  }
  static Future<void> resetCountersNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPlayedCount, 0);
    await prefs.setString(_keyLastReset, DateTime.now().toIso8601String());
  }


  static Future<Duration> timeLeft() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_keyLastReset);
    if (lastResetString == null) return Duration.zero;

    final lastReset = DateTime.tryParse(lastResetString);
    if (lastReset == null) return Duration.zero;

    final elapsed = DateTime.now().difference(lastReset);
    if (elapsed >= cooldown) return Duration.zero;
    return cooldown - elapsed;
  }

  static Future<void> saveScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final top = prefs.getInt(_keyTopStreak) ?? 0;
    // Save last session score
    await prefs.setInt(_keyLastScore, score);
    // Update top streak if new high score
    if (score > top) {
      await prefs.setInt(_keyTopStreak, score);
    }
  }

  static Future<int> getTopStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTopStreak) ?? 0;
  }

  static Future<int> getLastScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastScore) ?? 0;
  }
}
