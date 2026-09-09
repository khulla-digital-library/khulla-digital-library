import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/theme/cubit/theme_state.dart';
import 'package:khulla/core/theme/theme_storage.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// App-wide appearance: [ThemeMode] and the brand the product is painted in.
///
/// Both are read from [ThemeStorage] on startup and persisted on every change,
/// so the choice survives a restart. They are device settings, not library
/// ones — nothing here reaches the catalogue file.
@lazySingleton
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._storage)
    : super(
        ThemeState(
          mode: _storage.readThemeMode(),
          brandTheme: _storage.readBrandTheme(),
        ),
      );

  final ThemeStorage _storage;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state.mode == mode) return;
    emit(state.copyWith(mode: mode));
    await _storage.saveThemeMode(mode);
  }

  /// Cycles system → light → dark → system, for a single toolbar control.
  Future<void> cycleThemeMode() => setThemeMode(switch (state.mode) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });

  Future<void> setBrandTheme(AppBrandTheme brand) async {
    if (state.brandTheme == brand) return;
    emit(state.copyWith(brandTheme: brand));
    await _storage.saveBrandTheme(brand);
  }
}
