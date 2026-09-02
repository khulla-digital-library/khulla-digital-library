import 'package:go_router/go_router.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_attention_item.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Overdue loans, unfilled holds, memberships lapsing, copies reported lost.
///
/// The counterpart to the activity table: that one is what happened, this one
/// is what somebody still has to do. Every row opens the screen that clears
/// it, so the panel is a worklist rather than a worry list.
class DashboardAttentionSection extends StatelessWidget {
  const DashboardAttentionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final items = dashboardAttentionItems(l10n);

    return DashboardSectionCard(
      title: l10n.dashboardAttentionTitle,
      subtitle: l10n.dashboardAttentionSubtitle,
      icon: Icons.notification_important_outlined,
      child: items.isEmpty
          ? AppEmptyView(
              icon: Icons.check_circle_outline_rounded,
              title: l10n.dashboardAttentionEmptyTitle,
              message: l10n.dashboardAttentionEmptyBody,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, item) in items.indexed) ...[
                  if (index > 0) SizedBox(height: spacing.xs),
                  _AttentionRow(item: item),
                ],
              ],
            ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({required this.item});

  final DashboardAttentionItem item;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final radius = BorderRadius.circular(context.appRadius.control);

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xs,
            vertical: spacing.xs,
          ),
          child: Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: item.tone.background(context),
                  borderRadius: BorderRadius.circular(context.appRadius.tile),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    item.icon,
                    size: spacing.md,
                    color: item.tone.foreground(context),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 2,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textHigh,
                  ),
                ),
              ),
              SizedBox(width: spacing.xs),
              Text(
                item.count,
                style: context.textTheme.titleSmall?.copyWith(
                  color: item.tone.foreground(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: colors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
