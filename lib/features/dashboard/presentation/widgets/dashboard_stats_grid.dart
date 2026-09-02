import 'package:go_router/go_router.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_stat.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The row of figures at the top of the dashboard.
///
/// Four tiles across a window, two on a tablet, one on a phone — the grid
/// decides, so nothing here compares a width against a number.
///
/// Four, not six: the top of a dashboard is the one place where every figure
/// has to be readable without a second look, and the fifth tile is always the
/// one nobody reads.
class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({required this.stats, super.key});

  /// The figures to show, in reading order.
  final List<DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return AppResponsiveGrid(
      children: [
        for (final stat in stats)
          AppStatTile(
            label: stat.label,
            value: stat.value,
            caption: stat.caption,
            icon: stat.icon,
            tone: stat.tone,
            trend: stat.trend,
            trendValue: stat.trendValue,
            trendInverted: stat.trendInverted,
            onTap: stat.route == null ? null : () => context.go(stat.route!),
          ),
      ],
    );
  }
}
