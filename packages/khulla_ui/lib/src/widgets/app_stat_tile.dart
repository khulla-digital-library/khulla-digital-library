import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_stat_tile}
/// One number on a dashboard: a label, the figure, and an optional line of
/// context under it.
///
/// [value] is a ready-made string, which is what lets the same tile show a
/// count, a percentage and a money amount without the design system
/// learning how any of them are formatted.
/// {@endtemplate}
class AppStatTile extends StatelessWidget {
  /// {@macro app_stat_tile}
  const AppStatTile({
    required this.label,
    required this.value,
    this.caption,
    this.icon,
    this.tone = AppStatusTone.neutral,
    this.onTap,
    this.isLoading = false,
    super.key,
  });

  /// What is being counted.
  final String label;

  /// The figure itself, already formatted.
  final String value;

  /// A line of context under the figure — a comparison, a due date.
  final String? caption;

  /// Glyph in the tinted badge.
  final IconData? icon;

  /// Which semantic family the tile draws from. An *Overdue* tile is
  /// [AppStatusTone.danger]; a plain count is [AppStatusTone.neutral].
  final AppStatusTone tone;

  /// Opens the list behind the number. A stat nobody can drill into is a
  /// decoration, so wire it wherever a list exists.
  final VoidCallback? onTap;

  /// Shows a skeleton in place of the figure while the count is being read.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final glyph = icon;
    final captionText = caption;

    return AppCard(
      onTap: onTap,
      child: Column(
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
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (glyph != null)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: tone.background(context),
                    borderRadius: BorderRadius.circular(
                      context.appRadius.tile,
                    ),
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
            ],
          ),
          SizedBox(height: spacing.sm),
          if (isLoading)
            const AppSkeleton(width: 72, height: 28)
          else
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w500,
                letterSpacing: -0.5,
                color: tone == AppStatusTone.neutral
                    ? context.appColors.textHigh
                    : tone.foreground(context),
              ),
            ),
          if (captionText != null) ...[
            SizedBox(height: spacing.xxs),
            Text(
              captionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
