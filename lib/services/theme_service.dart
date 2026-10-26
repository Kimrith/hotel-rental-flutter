import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themePrefsKey = 'theme_mode';

  /// Loads the theme mode preference (returns true if dark mode is enabled).
  static Future<bool> isDarkMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_themePrefsKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Persists the theme mode preference.
  static Future<void> saveThemeMode(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefsKey, isDark);
    } catch (e) {
      // ignore or log
    }
  }
}
