import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_section_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What overdue copies have cost members, month by month.
///
/// A line rather than bars: the shape of the curve is the point — a library
/// wants to see fines *falling* after it changes a loan rule, which is a
/// trend, not a set of monthly comparisons.
class DashboardFinesCard extends StatelessWidget {
  const DashboardFinesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final series = dashboardFinesSeries(l10n);
    final latest = Money.major(series.first.points.last.value);

    return DashboardSectionCard(
      title: l10n.dashboardFinesTitle,
      subtitle: l10n.dashboardFinesSubtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            latest.display(),
            style: context.textTheme.titleSmall?.copyWith(
              color: context.appColors.textHigh,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: spacing.xs),
          const AppTrendPill(label: '-14%', value: -14, inverted: true),
        ],
      ),
      child: AppLineChart(series: series, highlightIndex: 6, showDots: true),
    );
  }
}
