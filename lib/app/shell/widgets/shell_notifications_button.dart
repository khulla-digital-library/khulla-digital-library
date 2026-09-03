import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The bell in the top bar.
///
/// A library's notifications are not messages, they are work: copies that
/// went overdue overnight, holds that arrived on the shelf, memberships
/// lapsing this week. Each row therefore navigates to the screen that clears
/// it rather than to an inbox that repeats it.
class ShellNotificationsButton extends StatelessWidget {
  const ShellNotificationsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return MenuAnchor(
      alignmentOffset: Offset(0, spacing.xs),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(context.colorScheme.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.appRadius.container),
            side: BorderSide(color: context.appColors.hairline),
          ),
        ),
        padding: WidgetStatePropertyAll(EdgeInsets.all(spacing.xs)),
      ),
      menuChildren: [
        SizedBox(
          width: 320,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  spacing.xs,
                  spacing.xs,
                  spacing.xs,
                  spacing.xs,
                ),
                child: Text(
                  l10n.shellNotificationsTitle,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: context.appColors.textHigh,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _NoticeRow(
                icon: Icons.error_outline_rounded,
                tone: AppStatusTone.danger,
                label: l10n.dashboardAttentionOverdue,
                count: '7',
                route: Routes.circulation,
              ),
              _NoticeRow(
                icon: Icons.bookmark_border_rounded,
                tone: AppStatusTone.info,
                label: l10n.dashboardAttentionHolds,
                count: '3',
                route: Routes.circulationReservations,
              ),
              _NoticeRow(
                icon: Icons.schedule_rounded,
                tone: AppStatusTone.warning,
                label: l10n.dashboardAttentionExpiring,
                count: '12',
                route: Routes.members,
              ),
            ],
          ),
        ),
      ],
      builder: (context, controller, _) => AppIconButton(
        icon: Icons.notifications_none_rounded,
        tooltip: l10n.shellNotifications,
        badge: true,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({
    required this.icon,
    required this.tone,
    required this.label,
    required this.count,
    required this.route,
  });

  final IconData icon;
  final AppStatusTone tone;
  final String label;
  final String count;
  final String route;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final radius = BorderRadius.circular(context.appRadius.control);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          context.go(route);
        },
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.all(spacing.xs),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tone.background(context),
                  borderRadius: BorderRadius.circular(
                    context.appRadius.container,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    icon,
                    size: spacing.md,
                    color: tone.foreground(context),
                  ),
                ),
              ),
              SizedBox(width: spacing.xs),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(width: spacing.xs),
              AppStatusBadge(
                label: count,
                tone: tone,
                dense: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
