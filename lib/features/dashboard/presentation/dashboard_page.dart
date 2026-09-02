import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_activity_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_collection_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_fines_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_ranked_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_subjects_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_usage_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The shell's landing tab: what the library looks like right now.
///
/// It is the app's densest page, and the only one laid out as two panes: the
/// left column is *what happened* — the figures, the charts, the desk's
/// activity — and the right rail is *what is still owed*, the worklist a
/// shift is judged by. Below `large` the rail folds under the column rather
/// than squeezing beside it, because a 300px chart is worse than no chart.
///
/// The board is a single [CustomScrollView]. Each section is a card in a
/// sliver, so the page scrolls as one surface and no section nests a
/// scrollable inside another — the rule that keeps a ten-thousand-title
/// catalogue openable applies here too.
///
/// Every figure is placeholder data until the tables exist. The layout, the
/// breakpoints and the empty copy are settled now so that building
/// circulation is a matter of dropping a cubit behind a section rather than
/// redesigning the page around it.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DashboardPeriod _period = DashboardPeriod.week;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final formFactor = context.formFactor;
    final twoPane = formFactor.usesExtendedRail;
    final sideBySide = formFactor.isAtLeast(FormFactor.expanded);

    final mainColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DashboardUsageCard(),
        SizedBox(height: spacing.md),
        if (sideBySide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(flex: 3, child: DashboardFinesCard()),
              SizedBox(width: spacing.md),
              const Expanded(flex: 2, child: DashboardCollectionCard()),
            ],
          )
        else ...[
          const DashboardFinesCard(),
          SizedBox(height: spacing.md),
          const DashboardCollectionCard(),
        ],
        SizedBox(height: spacing.md),
        const DashboardActivitySection(),
        SizedBox(height: spacing.md),
        const DashboardQuickActions(),
      ],
    );

    final sideColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DashboardAttentionSection(),
        SizedBox(height: spacing.md),
        DashboardRankedCard(
          title: l10n.dashboardTopTitlesTitle,
          icon: Icons.local_fire_department_outlined,
          subtitle: l10n.commonThisMonth,
          entries: dashboardTopTitles(l10n),
        ),
        SizedBox(height: spacing.md),
        DashboardRankedCard(
          title: l10n.dashboardTopMembersTitle,
          icon: Icons.emoji_events_outlined,
          subtitle: l10n.commonThisMonth,
          entries: dashboardTopMembers(l10n),
        ),
        SizedBox(height: spacing.md),
        const DashboardSubjectsCard(),
      ],
    );

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverList.list(
              children: [
                DashboardHeader(
                  period: _period,
                  onPeriodChanged: (period) => setState(() => _period = period),
                ),
                SizedBox(height: spacing.lg),
                DashboardStatsGrid(stats: dashboardPlaceholderStats(l10n)),
                SizedBox(height: spacing.lg),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: mainColumn),
                      SizedBox(width: spacing.md),
                      SizedBox(width: 340, child: sideColumn),
                    ],
                  )
                else ...[
                  mainColumn,
                  SizedBox(height: spacing.md),
                  sideColumn,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
