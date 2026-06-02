import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _highScoreKey = 'high_score_record';
  static const String _selectedSkinIdKey = 'selected_skin_id_record';
  static const String _selectedThemeIdKey = 'selected_theme_id_record';
  static const String _isMutedKey = 'is_muted_record';

  /// Fetches the stored high score, returning 0 if not set
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Saves a new high score to local storage
  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  /// Fetches the selected skin ID, returning 'default' if not set
  Future<String> getSelectedSkinId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedSkinIdKey) ?? 'default';
  }

  /// Saves the selected skin ID to local storage
  Future<void> saveSelectedSkinId(String skinId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedSkinIdKey, skinId);
  }

  /// Fetches the selected theme ID, returning 'theme_1' if not set
  Future<String> getSelectedThemeId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_selectedThemeIdKey) ?? 'theme_1';
  }

  /// Saves the selected theme ID to local storage
  Future<void> saveSelectedThemeId(String themeId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedThemeIdKey, themeId);
  }

  /// Fetches the sound mute status, returning false if not set
  Future<bool> getIsMuted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isMutedKey) ?? false;
  }

  /// Saves the sound mute status to local storage
  Future<void> saveIsMuted(bool isMuted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isMutedKey, isMuted);
  }
}
