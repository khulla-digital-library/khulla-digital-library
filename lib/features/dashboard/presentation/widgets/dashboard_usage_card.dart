import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Visits against loans, day by day.
///
/// Two grouped series rather than one stacked bar: the question this card
/// answers is whether the people who walked in borrowed anything, and a
/// stacked bar hides exactly that comparison inside its own total.
class DashboardUsageCard extends StatelessWidget {
  const DashboardUsageCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final series = dashboardUsageSeries(l10n);

    return DashboardSectionCard(
      title: l10n.dashboardUsageTitle,
      subtitle: l10n.dashboardUsageSubtitle,
      icon: Icons.bar_chart_rounded,
      trailing: Wrap(
        spacing: spacing.sm,
        children: [
          AppLegendDot(
            label: series.first.name,
            tone: series.first.tone,
            dense: true,
          ),
          AppLegendDot(
            label: series.last.name,
            tone: series.last.tone,
            dense: true,
          ),
        ],
      ),
      child: AppBarChart(series: series, highlightIndex: 4),
    );
  }
}
