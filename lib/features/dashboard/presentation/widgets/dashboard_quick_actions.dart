import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The four things a desk shift starts with, as pressable tiles.
///
/// Each one lands on the screen that does the task — the checkout desk, the
/// returns desk, an empty title editor, an empty member editor — rather than
/// on the section that contains it.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppResponsiveGrid(
      compactColumns: 2,
      expandedColumns: 4,
      children: [
        _QuickActionTile(
          label: l10n.dashboardCheckOut,
          icon: Icons.qr_code_scanner_rounded,
          route: Routes.circulationCheckOut,
        ),
        _QuickActionTile(
          label: l10n.dashboardReturnCopy,
          icon: Icons.assignment_return_outlined,
          route: Routes.circulationReturn,
        ),
        _QuickActionTile(
          label: l10n.dashboardAddTitle,
          icon: Icons.library_add_outlined,
          route: Routes.catalogTitleNew,
        ),
        _QuickActionTile(
          label: l10n.dashboardAddMember,
          icon: Icons.person_add_alt_1_outlined,
          route: Routes.memberNew,
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return AppCard(
      onTap: () => context.go(route),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.appRadius.tile),
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing.xs),
              child: Icon(icon, size: spacing.md + 4, color: scheme.primary),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
