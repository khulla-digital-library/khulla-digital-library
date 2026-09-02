import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// Shared press, hover, and focus overlay feedback for Material buttons.
///
/// Overlays are derived from [AppPalette.brandSeed] rather than the ambient
/// [ColorScheme] because they are resolved during theme construction, where
/// no [BuildContext] exists. The alphas are low enough to read correctly on
/// both light and dark fills.
abstract final class AppButtonInteraction {
  static Color _brand(double alpha) =>
      AppPalette.brandSeed.withValues(alpha: alpha);

  /// Merges tactile overlay feedback into a [ButtonStyle].
  ///
  /// [focusedOverlay] matters on desktop and web, where a control is commonly
  /// reached by Tab rather than by pointer and needs a visible resting state.
  static ButtonStyle merge(
    ButtonStyle? style, {
    required Color pressedOverlay,
    Color? hoveredOverlay,
    Color? focusedOverlay,
  }) {
    final base = style ?? const ButtonStyle();

    return base.copyWith(
      splashFactory: InkRipple.splashFactory,
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;
        if (states.contains(WidgetState.pressed)) return pressedOverlay;
        if (hoveredOverlay != null && states.contains(WidgetState.hovered)) {
          return hoveredOverlay;
        }
        if (focusedOverlay != null && states.contains(WidgetState.focused)) {
          return focusedOverlay;
        }
        return null;
      }),
      mouseCursor: const WidgetStateProperty<MouseCursor?>.fromMap(
        <WidgetStatesConstraint, MouseCursor?>{
          WidgetState.disabled: SystemMouseCursors.basic,
          WidgetState.any: SystemMouseCursors.click,
        },
      ),
    );
  }

  /// Filled / tonal CTAs on brand or dark fills.
  static ButtonStyle filled(ButtonStyle? style) => merge(
    style,
    pressedOverlay: _brand(0.22),
    hoveredOverlay: _brand(0.10),
    focusedOverlay: _brand(0.14),
  );

  /// Outlined buttons on light and dark surfaces.
  static ButtonStyle outlined(ButtonStyle? style) => merge(
    style,
    pressedOverlay: _brand(0.14),
    hoveredOverlay: _brand(0.06),
    focusedOverlay: _brand(0.10),
  );

  /// Low-emphasis text actions.
  static ButtonStyle text(ButtonStyle? style) => merge(
    style,
    pressedOverlay: _brand(0.14),
    hoveredOverlay: _brand(0.05),
    focusedOverlay: _brand(0.09),
  );
}
