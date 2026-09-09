// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla_ui/khulla_ui.dart';

part 'theme_state.freezed.dart';

/// The two device-level appearance choices: light or dark, and which brand the
/// product is painted in. Both are read from storage at startup, so the app's
/// first frame is already the operator's.
@freezed
abstract class ThemeState with _$ThemeState {
  const factory ThemeState({
    @Default(ThemeMode.light) ThemeMode mode,
    @Default(AppBrandTheme.teal) AppBrandTheme brandTheme,
    Color? customSeed,
  }) = _ThemeState;

  const ThemeState._();

  /// The ramp the theme is built from. A mixed color wins over the preset,
  /// which stays put underneath as what the row falls back to.
  AppBrand get brand => switch (customSeed) {
    final seed? => AppBrand.fromSeed(seed),
    _ => brandTheme.brand,
  };

  /// The color the ramp is built from, preset or mixed.
  Color get brandSeed => customSeed ?? brandTheme.seed;
}
