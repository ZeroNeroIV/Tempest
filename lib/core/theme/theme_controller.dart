import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'corner_style.dart';

/// Manages application-wide theme mode (light/dark) and corner style (rounded/sharp).
class ThemeController extends ChangeNotifier {
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.dark;
  CornerStyle _cornerStyle = CornerStyle.rounded;

  ThemeController(this._prefs) {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  CornerStyle get cornerStyle => _cornerStyle;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadFromPrefs() {
    final modeStr = _prefs.getString(AppConstants.keyThemeMode);
    if (modeStr != null) {
      _themeMode = modeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    }

    final cornerStr = _prefs.getString(AppConstants.keyCornerStyle);
    if (cornerStr != null) {
      _cornerStyle = cornerStr == 'sharp' ? CornerStyle.sharp : CornerStyle.rounded;
    }
  }

  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _prefs.setString(
      AppConstants.keyThemeMode,
      _themeMode == ThemeMode.light ? 'light' : 'dark',
    );
    notifyListeners();
  }

  Future<void> toggleCornerStyle() async {
    _cornerStyle = _cornerStyle == CornerStyle.rounded ? CornerStyle.sharp : CornerStyle.rounded;
    await _prefs.setString(
      AppConstants.keyCornerStyle,
      _cornerStyle == CornerStyle.sharp ? 'sharp' : 'rounded',
    );
    notifyListeners();
  }
}
