import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Product mark pinned to the top of the navigation rail.
///
/// Collapses to the monogram alone when the rail is not [extended], so it
/// keeps the rail's width rather than forcing it wider.
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
        color: scheme.primary,
        borderRadius: BorderRadius.circular(context.appRadius.tile),
      ),
      alignment: Alignment.center,
      child: Text(
        'K',
        style: context.textTheme.titleMedium?.copyWith(
          color: scheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (!extended) {
      return Tooltip(message: l10n.appName, child: monogram);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.md),
      child: Row(
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
                  ),
                ),
                Text(
                  l10n.appTagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
