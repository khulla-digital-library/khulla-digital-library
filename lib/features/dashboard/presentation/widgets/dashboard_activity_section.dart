import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Recent checkouts and returns.
///
/// Blank by design until circulation has tables behind it: the section is
/// wired, sized and titled, and the only thing missing is the query. When
/// `CirculationCubit` lands this becomes the four-state block the design
/// standards call for — loading, error, empty, content — with the empty state
/// already written here.
class DashboardActivitySection extends StatelessWidget {
  const DashboardActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return DashboardSectionCard(
      title: l10n.dashboardActivityTitle,
      subtitle: l10n.dashboardActivitySubtitle,
      icon: Icons.history_rounded,
      child: AppEmptyView(
        icon: Icons.swap_horiz_rounded,
        title: l10n.dashboardActivityEmptyTitle,
        message: l10n.dashboardActivityEmptyBody,
      ),
    );
  }
}
