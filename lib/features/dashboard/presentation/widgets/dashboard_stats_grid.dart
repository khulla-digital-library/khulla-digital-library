import 'package:go_router/go_router.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_stat.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The row of figures at the top of the dashboard.
///
/// Six tiles across a maximised window, three at 840px, two on a tablet and
/// one on a phone — the grid decides, so nothing here compares a width
/// against a number.
class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({required this.stats, super.key});

  /// The figures to show, in reading order.
  final List<DashboardStat> stats;

  @override
  Widget build(BuildContext context) {
    return AppResponsiveGrid(
      largeColumns: 3,
      children: [
        for (final stat in stats)
          AppStatTile(
            label: stat.label,
            value: stat.value,
            caption: stat.caption,
            icon: stat.icon,
            tone: stat.tone,
            onTap: stat.route == null ? null : () => context.go(stat.route!),
          ),
      ],
    );
  }
}
