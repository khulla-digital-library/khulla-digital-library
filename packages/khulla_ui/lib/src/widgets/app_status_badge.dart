import 'package:khulla_ui/khulla_ui.dart';

/// The standing pill — *Available*, *Overdue*, *Reserved*, *Active*.
///
/// A wash, a hairline and a leading dot, never a solid fill: a table of forty
/// rows with forty saturated pills is unreadable, and the dot carries the
/// state for anyone who cannot separate the hues. The tone decides all three
/// colors, so the same standing looks identical in a table, a card and a
/// detail header.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
    this.dense = false,
    this.showDot = true,
    super.key,
  });

  /// The standing, already localized.
  final String label;

  /// Which meaning to paint.
  final AppStatusTone tone;

  /// Replaces the dot with a glyph, where one says more than a color does.
  final IconData? icon;

  /// Tightens the pill for use inside a table row.
  final bool dense;

  /// Whether to draw the leading dot. Turn it off only when the label is
  /// already unambiguous without color — a count, a plan name.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final foreground = tone.foreground(context);
    final glyph = icon;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tone.background(context),
        borderRadius: BorderRadius.circular(context.appRadius.pill),
        border: Border.all(color: tone.border(context)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? spacing.xs : spacing.sm - 2,
          vertical: dense ? spacing.xxs / 2 : spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Icon(glyph, size: spacing.sm, color: foreground),
              SizedBox(width: spacing.xxs),
            ] else if (showDot) ...[
              Container(
                width: spacing.xxs + 2,
                height: spacing.xxs + 2,
                decoration: BoxDecoration(
                  color: foreground,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.xxs + 2),
            ],
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
