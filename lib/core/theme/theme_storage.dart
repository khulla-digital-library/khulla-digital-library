import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin, typed wrapper around [SharedPreferences] for the user's theme choice.
@lazySingleton
class ThemeStorage {
  ThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'khulla.theme_mode';

  /// The persisted choice, or [ThemeMode.system] when none was saved yet.
  ThemeMode readThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);
}
