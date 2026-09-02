import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_status_tone}
/// The semantic colour families a badge, chip or stat tile can take.
///
/// Named by meaning rather than by colour, so a status that changes hue in a
/// future theme does not need every call site rewritten. Khulla's library
/// vocabulary maps onto them like this:
///
/// | Tone | Reads as |
/// | --- | --- |
/// | [neutral] | Draft, archived, no standing |
/// | [success] | Available, returned on time, active member |
/// | [warning] | Due soon, last copy out, membership expiring |
/// | [info] | Reserved, on hold, imported |
/// | [danger] | Overdue, lost, suspended |
/// | [brand] | On loan, in progress — the app's own accent |
/// {@endtemplate}
enum AppStatusTone {
  /// No standing of its own.
  neutral,

  /// Everything is as it should be.
  success,

  /// Needs attention soon, but nothing has gone wrong yet.
  warning,

  /// Informational: a state someone chose, not a problem.
  info,

  /// Something has gone wrong and is costing the library.
  danger,

  /// The app's own accent, for an in-progress state.
  brand,
}

/// Resolves an [AppStatusTone] against the ambient theme.
extension AppStatusToneColors on AppStatusTone {
  /// The tone's foreground (text and glyph) colour.
  Color foreground(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.appColors;
    return switch (this) {
      AppStatusTone.neutral => scheme.onSurfaceVariant,
      AppStatusTone.success => colors.success,
      AppStatusTone.warning => colors.warning,
      AppStatusTone.info => colors.info,
      AppStatusTone.danger => scheme.error,
      AppStatusTone.brand => scheme.primary,
    };
  }

  /// The tone's fill, a low-alpha wash of [foreground] over the card surface.
  ///
  /// Blended rather than translucent so a badge keeps its colour when it sits
  /// on a tinted row or a selected card.
  Color background(BuildContext context) {
    final scheme = context.colorScheme;
    if (this == AppStatusTone.neutral) {
      return scheme.surfaceContainerHighest.withValues(alpha: 0.7);
    }
    return Color.alphaBlend(
      foreground(context).withValues(alpha: 0.12),
      scheme.surface,
    );
  }
}
