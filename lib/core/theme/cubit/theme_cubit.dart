import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/theme/theme_storage.dart';

/// App-wide [ThemeMode], read from [ThemeStorage] on startup and persisted on
/// every change so the user's choice survives app restarts.
@lazySingleton
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._storage) : super(_storage.readThemeMode());

  final ThemeStorage _storage;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    await _storage.saveThemeMode(mode);
  }

  /// Cycles system → light → dark → system, for a single toolbar control.
  Future<void> cycleThemeMode() => setThemeMode(switch (state) {
    ThemeMode.system => ThemeMode.light,
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
  });
}
