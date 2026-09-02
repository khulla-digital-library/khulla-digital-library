import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_card}
/// The standard raised surface: a [ColorScheme.surface] fill on the muted
/// page canvas, rounded at [AppRadius.card], padded at [AppSpacing.md].
///
/// Fill is deliberately `surface` and not `surfaceContainerHighest` — the
/// latter is the same colour as the scaffold, so a card filled with it
/// disappears against the page. Use `surfaceContainerHighest` for tints
/// *inside* a card instead.
///
/// Pass [onTap] to make the whole card a target; it picks up hover, focus and
/// ink feedback, which is what a pointer-driven desk tool needs.
/// {@endtemplate}
class AppCard extends StatelessWidget {
  /// {@macro app_card}
  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    this.selected = false,
    this.bordered = true,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  /// Card content.
  final Widget child;

  /// Overrides the default [AppSpacing.md] inset. Pass [EdgeInsets.zero] for
  /// a card whose child paints to the edge — a table, a list.
  final EdgeInsetsGeometry? padding;

  /// Makes the whole card pressable.
  final VoidCallback? onTap;

  /// Draws the border and a faint fill in the brand colour, for a card that
  /// is the current row or the chosen option.
  final bool selected;

  /// Whether to hairline the card. Turn off inside an already-bordered group.
  final bool bordered;

  /// How the card clips [child]. Defaults to anti-aliased so a full-bleed
  /// image or table header follows the corner radius.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(context.appRadius.card),
      side: bordered
          ? BorderSide(
              color: selected
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.6),
              width: selected ? 1.5 : 1,
            )
          : BorderSide.none,
    );

    final body = Padding(
      padding: padding ?? EdgeInsets.all(spacing.md),
      child: child,
    );

    return Material(
      color: selected
          ? Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.05),
              scheme.surface,
            )
          : scheme.surface,
      shape: shape,
      clipBehavior: clipBehavior,
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              hoverColor: scheme.primary.withValues(alpha: 0.04),
              focusColor: scheme.primary.withValues(alpha: 0.08),
              child: body,
            ),
    );
  }
}
