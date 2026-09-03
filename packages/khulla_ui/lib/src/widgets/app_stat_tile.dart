import 'package:khulla_ui/khulla_ui.dart';

/// One figure on a board: what it counts, the number, and which way it moved.
///
/// The figure is the only loud thing in the tile. The label sits above it in
/// muted body copy and the glyph is drawn bare on the trailing edge, because
/// a tinted square around an icon puts a second surface inside a tile that is
/// already a surface, and a row of four of them reads as decoration competing
/// with the numbers it is supposed to introduce.
///
/// Set [framed] to false to drop the card and let a host draw the surface —
/// that is how [AppStatStrip] turns a row of figures into one instrument
/// panel divided by hairlines rather than four separate floating cards.
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
    this.framed = true,
    super.key,
  });

  /// What the figure counts — *Books borrowed*, *Overdue returns*.
  final String label;

  /// The figure itself, already formatted and localized.
  final String value;

  /// The line under the figure — the period it covers, or what the delta is
  /// measured against.
  final String? caption;

  /// The glyph on the trailing edge of the label row.
  final IconData? icon;

  /// The tone of the glyph, and of the figure when it is not neutral.
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

  /// Whether the tile draws its own card. False when a host surface — an
  /// [AppStatStrip] — already provides one.
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final glyph = icon;
    final captionText = caption;
    final delta = trend;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
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
            if (glyph != null) ...[
              SizedBox(width: spacing.xs),
              Icon(glyph, size: spacing.md, color: tone.foreground(context)),
            ],
          ],
        ),
        SizedBox(height: spacing.xs),
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
    );

    if (framed) {
      return AppCard(
        onTap: onTap,
        padding: EdgeInsets.all(spacing.md),
        child: body,
      );
    }

    final tap = onTap;
    final padded = Padding(padding: EdgeInsets.all(spacing.md), child: body);
    if (tap == null) return padded;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: tap,
        focusColor: context.colorScheme.primary.withValues(alpha: 0.06),
        child: padded,
      ),
    );
  }
}
