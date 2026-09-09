import 'package:khulla_ui/khulla_ui.dart';

/// The resolved colors of one [AppButtonVariant].
class AppButtonStyle {
  const AppButtonStyle({
    required this.fill,
    required this.hoverFill,
    required this.foreground,
    required this.border,
    required this.ripple,
    required this.ring,
    this.shadowed = true,
  });

  final Color fill;
  final Color hoverFill;
  final Color foreground;
  final Color border;
  final Color ripple;
  final Color ring;
  final bool shadowed;
}

/// Maps an [AppButtonVariant] to its colors. Kept out of the button's state
/// so the 9-way switch can be read without the gesture and focus noise.
class AppButtonStyler {
  const AppButtonStyler._();

  static AppButtonStyle resolve(
    BuildContext context,
    AppButtonVariant variant,
  ) {
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final tints = colors.tints;
    return switch (variant) {
      AppButtonVariant.primary => AppButtonStyle(
        fill: colors.brand,
        hoverFill: colors.brandStrong,
        foreground: scheme.onPrimary,
        border: colors.brandStrong.withValues(alpha: 0.7),
        ripple: colors.secondary,
        ring: colors.brand,
      ),
      AppButtonVariant.destructive => AppButtonStyle(
        fill: Colors.transparent,
        hoverFill: tints.destructiveHover,
        foreground: colors.danger,
        border: colors.danger,
        ripple: colors.danger.withValues(alpha: 0.2),
        ring: colors.danger,
      ),
      AppButtonVariant.destructiveFilled => AppButtonStyle(
        fill: colors.danger,
        hoverFill: colors.danger.withValues(alpha: 0.9),
        foreground: colors.onDanger,
        border: colors.danger.withValues(alpha: 0.7),
        ripple: colors.secondary,
        ring: colors.danger,
      ),
      AppButtonVariant.outline => AppButtonStyle(
        fill: scheme.surface,
        hoverFill: colors.secondary,
        foreground: colors.ink500,
        border: colors.hairline,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
      ),
      AppButtonVariant.secondary => AppButtonStyle(
        fill: colors.secondary,
        hoverFill: colors.hairlineStrong.withValues(alpha: 0.5),
        foreground: colors.ink100,
        border: Colors.transparent,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
      ),
      // A transparent border, not the absence of one: a ghost button that
      // grows a border on hover would shift everything beside it.
      AppButtonVariant.ghost => AppButtonStyle(
        fill: Colors.transparent,
        hoverFill: colors.secondary,
        foreground: scheme.primary,
        border: Colors.transparent,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
        shadowed: false,
      ),
      AppButtonVariant.success => AppButtonStyle(
        fill: colors.success,
        hoverFill: colors.success.withValues(alpha: 0.9),
        foreground: colors.onSuccess,
        border: colors.success.withValues(alpha: 0.7),
        ripple: colors.secondary,
        ring: colors.success,
      ),
      AppButtonVariant.successOutline => AppButtonStyle(
        fill: Colors.transparent,
        hoverFill: tints.successHover,
        foreground: colors.success,
        border: colors.success,
        ripple: colors.success.withValues(alpha: 0.2),
        ring: colors.success,
      ),
      AppButtonVariant.link => AppButtonStyle(
        fill: Colors.transparent,
        hoverFill: Colors.transparent,
        foreground: colors.link,
        border: Colors.transparent,
        ripple: Colors.transparent,
        ring: Colors.transparent,
        shadowed: false,
      ),
    };
  }
}
