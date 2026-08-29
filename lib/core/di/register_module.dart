import 'package:injectable/injectable.dart';
import 'package:khulla/core/theme/theme_storage.dart' show ThemeStorage;
import 'package:shared_preferences/shared_preferences.dart';

/// Registers third-party dependencies that injectable cannot construct on its
/// own (no annotated constructor).
@module
abstract class RegisterModule {
  /// Resolved before the first frame so [ThemeStorage] can read synchronously
  /// and the app never flashes the wrong theme on startup.
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();
}
