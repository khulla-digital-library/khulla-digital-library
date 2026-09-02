import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Overdue loans, unfilled holds, and copies reported lost.
///
/// The counterpart to the activity section: that one is what happened, this
/// one is what somebody has to do. Blank until circulation exists.
class DashboardAttentionSection extends StatelessWidget {
  const DashboardAttentionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DashboardSectionCard(
      title: l10n.dashboardAttentionTitle,
      subtitle: l10n.dashboardAttentionSubtitle,
      icon: Icons.notification_important_outlined,
      child: AppEmptyView(
        icon: Icons.check_circle_outline_rounded,
        title: l10n.dashboardAttentionEmptyTitle,
        message: l10n.dashboardAttentionEmptyBody,
      ),
    );
  }
}
