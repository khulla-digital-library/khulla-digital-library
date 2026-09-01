import 'package:go_router/go_router.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A door from a section's overview into one of the lists behind it.
///
/// A tile rather than a nav item: an overview page is where a librarian
/// decides what they are working on, and each door carries the count or the
/// standing that makes the decision.
class NavigationTile extends StatelessWidget {
  const NavigationTile({
    required this.label,
    required this.description,
    required this.icon,
    required this.route,
    this.count,
    super.key,
  });

  /// What is behind the door.
  final String label;

  /// A line explaining what is behind the door.
  final String description;

  /// How many records are in it, already formatted. Null hides the figure —
  /// a door into a desk flow is not counting anything.
  final String? count;

  /// Glyph in the tinted square.
  final IconData icon;

  /// Where the tile leads.
  final String route;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return AppCard(
      onTap: () => context.go(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(context.appRadius.tile),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    icon,
                    size: spacing.md + 4,
                    color: scheme.primary,
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (count case final figure?)
                Text(
                  figure,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: context.appColors.textHigh,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
