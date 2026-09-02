import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Product mark pinned to the top of the navigation rail.
///
/// Collapses to the monogram alone when the rail is not [extended], so it
/// keeps the rail's width rather than forcing it wider. The mark is drawn
/// rather than shipped as an asset: three ascending strokes on the brand
/// square read as books on a shelf at 32px, which a raster logo does not.
class ShellBrandMark extends StatelessWidget {
  const ShellBrandMark({required this.extended, super.key});

  /// Whether the rail is showing labels beside its icons.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final l10n = context.l10n;

    final monogram = Container(
      width: spacing.xlg,
      height: spacing.xlg,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, context.appColors.brandDeep],
        ),
        borderRadius: BorderRadius.circular(context.appRadius.tile),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.auto_stories_rounded,
        size: spacing.md + 2,
        color: scheme.onPrimary,
      ),
    );

    if (!extended) {
      return Tooltip(message: l10n.appName, child: monogram);
    }

    return Row(
      children: [
        monogram,
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                  color: context.appColors.textHigh,
                ),
              ),
              Text(
                l10n.appTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.appColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
