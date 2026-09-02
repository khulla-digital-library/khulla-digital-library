import 'package:khulla_ui/khulla_ui.dart';

/// One figure on a board: what it counts, what it is, and which way it moved.
///
/// The layout is fixed on purpose — glyph and label on one line, the figure
/// beneath it, the delta and its caption last — so a row of six tiles reads
/// as one instrument panel instead of six differently-arranged cards. The
/// figure is the only thing allowed to be large.
class AppStatTile extends StatelessWidget {
  const AppStatTile({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.tone = AppStatusTone.neutral,
    this.trend,
    this.trendValue = 0,
    this.trendInverted = false,
    this.onTap,
    this.isLoading = false,
    super.key,
  });

  /// What the figure counts — *Books borrowed*, *Overdue returns*.
  final String label;

  /// The figure itself, already formatted and localized.
  final String value;

  /// The line under the figure — the period it covers, or what the delta is
  /// measured against.
  final String? caption;

  /// The glyph in the tile's leading chip.
  final IconData? icon;

  /// The tone of the glyph chip, and of the figure when it is not neutral.
  final AppStatusTone tone;

  /// The delta label, if this figure has a comparison period (`+8.2%`).
  final String? trend;

  /// The delta's sign. Only the sign is read; the text comes from [trend].
  final num trendValue;

  /// Whether a fall is the improvement — overdue, fines, damaged copies.
  final bool trendInverted;

  /// Makes the tile a link to the screen that explains the figure.
  final VoidCallback? onTap;

  /// Renders the figure as a skeleton while the query is in flight.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final glyph = icon;
    final captionText = caption;
    final delta = trend;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (glyph != null) ...[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tone.background(context),
                    borderRadius: BorderRadius.circular(context.appRadius.tile),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.xs),
                    child: Icon(
                      glyph,
                      size: spacing.md,
                      color: tone.foreground(context),
                    ),
                  ),
                ),
                SizedBox(width: spacing.xs + 2),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          if (isLoading)
            const AppSkeleton(width: 96, height: 30)
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                color: colors.textHigh,
              ),
            ),
          if (delta != null || captionText != null) ...[
            SizedBox(height: spacing.xs),
            Row(
              children: [
                if (delta != null) ...[
                  AppTrendPill(
                    label: delta,
                    value: trendValue,
                    inverted: trendInverted,
                    dense: true,
                  ),
                  SizedBox(width: spacing.xs),
                ],
                if (captionText != null)
                  Expanded(
                    child: Text(
                      captionText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
