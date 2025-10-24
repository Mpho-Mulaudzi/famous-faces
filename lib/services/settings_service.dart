import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyShowFacts = 'showFacts';

  /// Loads whether the user wants to see facts after each quiz.
  static Future<bool> shouldShowFacts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowFacts) ?? true;
  }

  /// Saves the toggle value when changed in SettingsScreen.
  static Future<void> setShowFacts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowFacts, value);
  }
}