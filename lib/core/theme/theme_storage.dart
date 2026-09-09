import 'package:injectable/injectable.dart';
import 'package:khulla_ui/khulla_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin, typed wrapper around [SharedPreferences] for the user's appearance
/// choices.
///
/// Both are stored by enum name rather than by index, so reordering
/// [AppBrandTheme] cannot silently repaint every install, and a name that no
/// longer exists falls back to the default instead of throwing.
@lazySingleton
class ThemeStorage {
  ThemeStorage(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'khulla.theme_mode';
  static const String _brandThemeKey = 'khulla.brand_theme';

  /// The persisted choice, or [ThemeMode.light] when none was saved yet.
  ThemeMode readThemeMode() {
    final value = _prefs.getString(_themeModeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.light,
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  /// The persisted brand, or [AppBrandTheme.teal] when none was saved yet.
  AppBrandTheme readBrandTheme() {
    final value = _prefs.getString(_brandThemeKey);
    return AppBrandTheme.values.firstWhere(
      (brand) => brand.name == value,
      orElse: () => AppBrandTheme.teal,
    );
  }

  Future<void> saveBrandTheme(AppBrandTheme brand) =>
      _prefs.setString(_brandThemeKey, brand.name);
}
