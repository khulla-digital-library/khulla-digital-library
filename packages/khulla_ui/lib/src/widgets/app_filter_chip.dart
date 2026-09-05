import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_filter_chip}
/// One toggleable filter in a toolbar's chip row, with an optional count.
///
/// A plain card — 1px hairline, small corners, no fill — that stays neutral
/// at rest and switches to a [tone]-tinted border and wash once applied.
/// Matches the product's real card language rather than a rounded pill.
///
/// Chips are additive filters that can all be off at once; when exactly one
/// choice must always be active, that is [AppSegmentedControl] instead.
/// {@endtemplate}
class AppFilterChip extends StatelessWidget {
  /// {@macro app_filter_chip}
  const AppFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.count,
    this.icon,
    this.tone = AppStatusTone.brand,
    super.key,
  });

  /// The filter's localized name.
  final String label;

  /// Whether the filter is currently applied.
  final bool selected;

  /// Called with the next state. Null disables the chip.
  final ValueChanged<bool>? onSelected;

  /// How many records match, shown after the label. Null hides the count —
  /// which is the right choice while the count is still loading, rather than
  /// showing a zero that is not yet true.
  final int? count;

  /// Optional leading glyph.
  final AppIconSpec? icon;

  /// Which semantic family the selected state draws from. Use
  /// [AppStatusTone.danger] for an *Overdue* chip so the row reads at a
  /// glance.
  final AppStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final accent = tone.foreground(context);
    final glyph = icon;
    final total = count;
    final enabled = onSelected != null;
    final foreground = selected ? accent : colors.ink500;
    final radius = BorderRadius.circular(context.appRadius.container);

    final body = Container(
      height: metrics.buttonHeightSmall,
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      decoration: BoxDecoration(
        color: selected ? tone.background(context) : Colors.transparent,
        borderRadius: radius,
        border: Border.all(
          color: selected ? tone.border(context) : colors.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected) ...[
            AppIcon(
              AppIcons.check,
              size: metrics.iconInButton,
              color: foreground,
            ),
            SizedBox(width: spacing.xs - 2),
          ] else if (glyph != null) ...[
            AppIcon(glyph, size: metrics.iconInButton, color: foreground),
            SizedBox(width: spacing.xs - 2),
          ],
          Text(
            label,
            style: context.appTextStyles.label.copyWith(color: foreground),
          ),
          if (total != null) ...[
            SizedBox(width: spacing.xs - 2),
            Text(
              '$total',
              style: context.appTextStyles.label.copyWith(
                color: foreground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );

    return AppRipple(
      onTap: enabled ? () => onSelected!(!selected) : null,
      borderRadius: radius,
      pressScale: 1,
      child: body,
    );
  }
}
