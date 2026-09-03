import 'package:khulla_ui/khulla_ui.dart';

/// The standing pill — *Available*, *Overdue*, *Reserved*, *Active*.
///
/// One hue, three ways: an 8% wash, the hue at full strength for the text,
/// and a hairline in between. A table of forty rows with forty saturated
/// pills is unreadable, and a wash keeps the row's text the thing being read.
///
/// It is small on purpose — 10px semibold in a 10/2px pill — because in this
/// product a status sits *inside* a table cell, next to a title, and a badge
/// that matches the body size competes with it.
///
/// The label always names the standing, so hue is never the only channel
/// carrying it. [showDot] adds a second one where a badge appears without its
/// column header nearby.
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    required this.label,
    this.tone = AppStatusTone.neutral,
    this.icon,
    this.dense = false,
    this.showDot = false,
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

  /// Draws a leading dot in the status hue. Off by default; turn it on for a
  /// badge that stands alone, away from the column that names what it is.
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
          vertical: dense ? 1 : spacing.xxs / 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (glyph != null) ...[
              Icon(
                glyph,
                size: context.appMetrics.iconDense,
                color: foreground,
              ),
              SizedBox(width: spacing.xxs),
            ] else if (showDot) ...[
              Container(
                width: spacing.xxs + 1,
                height: spacing.xxs + 1,
                decoration: BoxDecoration(
                  color: foreground,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: spacing.xxs + 2),
            ],
            // Flexible, not bare: a badge is routinely dropped into a fixed
            // -width table column, and a min-size Row would overflow rather
            // than let the label ellipsise.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.appTextStyles.micro.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
