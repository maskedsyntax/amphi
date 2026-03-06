import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { classic, neubrutalism }

class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadTheme();
    return AppThemeMode.classic;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_key);
    if (savedTheme == 'neubrutalism') {
      state = AppThemeMode.neubrutalism;
    } else {
      state = AppThemeMode.classic;
    }
  }

  Future<void> toggleTheme() async {
    state = state == AppThemeMode.classic
        ? AppThemeMode.neubrutalism
        : AppThemeMode.classic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, state.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

class DarkModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; // Default to dark mode
  }

  void toggle() {
    state = !state;
  }
  
  void set(bool value) {
    state = value;
  }
}

final isDarkModeProvider = NotifierProvider<DarkModeNotifier, bool>(() {
  return DarkModeNotifier();
});
