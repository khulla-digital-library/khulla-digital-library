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
  }) = _ThemeState;

  const ThemeState._();

  /// The ramp the theme is built from.
  AppBrand get brand => brandTheme.brand;
}
