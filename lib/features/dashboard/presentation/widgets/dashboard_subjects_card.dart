import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// How the catalogue divides by subject.
///
/// Bars on a shared scale rather than a second pie: six categories in a pie
/// are six slices nobody can rank, while six bars starting from the same edge
/// are ranked at a glance.
class DashboardSubjectsCard extends StatelessWidget {
  const DashboardSubjectsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final subjects = dashboardSubjectShares();

    return DashboardSectionCard(
      title: l10n.dashboardCategoriesTitle,
      subtitle: l10n.dashboardCategoriesSubtitle,
      icon: Icons.category_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, subject) in subjects.indexed) ...[
            if (index > 0) SizedBox(height: spacing.sm),
            AppProgressBar(
              value: subject.share,
              label: subject.label,
              valueLabel: subject.count,
              tone: index == 0 ? AppStatusTone.brand : AppStatusTone.info,
            ),
          ],
        ],
      ),
    );
  }
}
