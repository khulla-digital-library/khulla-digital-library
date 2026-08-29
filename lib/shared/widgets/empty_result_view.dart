import 'package:khulla_ui/khulla_ui.dart';

/// Centered empty-state copy for a search or list that came back with nothing.
class EmptyResultView extends StatelessWidget {
  const EmptyResultView({
    required this.title,
    required this.subtitle,
    super.key,
    this.icon = Icons.search_off_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.page,
        vertical: spacing.xlg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: spacing.xlg, color: scheme.onSurfaceVariant),
          SizedBox(height: spacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
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
