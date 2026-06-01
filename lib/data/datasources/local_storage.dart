import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _highScoreKey = 'high_score_record';

  /// Fetches the stored high score, returning 0 if not set
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  /// Saves a new high score to the local storage
  Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }
}
