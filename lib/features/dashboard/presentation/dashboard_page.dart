import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_activity_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_collection_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_fines_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_ranked_card.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_stats_strip.dart';
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
/// Surface is used as hierarchy rather than as decoration. The figures share
/// one bordered strip; the three charts keep a card each, because a plot
/// needs a bounded drawing area to be read against; and the lists — the
/// worklist, the two rankings, the subject bars — sit on the page canvas
/// under their headings, since a list already has an edge and a border round
/// it only adds another rectangle.
///
/// The board is a single [CustomScrollView], so the page scrolls as one
/// surface and no section nests a scrollable inside another — the rule that
/// keeps a ten-thousand-title catalogue openable applies here too.
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
        SizedBox(height: spacing.lg),
        AppSectionHeader(
          title: l10n.dashboardQuickActionsTitle,
          subtitle: l10n.dashboardQuickActionsSubtitle,
        ),
        SizedBox(height: spacing.sm),
        const DashboardQuickActions(),
      ],
    );

    final sideColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DashboardAttentionSection(),
        SizedBox(height: spacing.lg),
        DashboardRankedCard(
          title: l10n.dashboardTopTitlesTitle,
          subtitle: l10n.commonThisMonth,
          entries: dashboardTopTitles(l10n),
        ),
        SizedBox(height: spacing.lg),
        DashboardRankedCard(
          title: l10n.dashboardTopMembersTitle,
          subtitle: l10n.commonThisMonth,
          entries: dashboardTopMembers(l10n),
        ),
        SizedBox(height: spacing.lg),
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
                SizedBox(height: spacing.md),
                DashboardStatsStrip(stats: dashboardPlaceholderStats(l10n)),
                SizedBox(height: spacing.lg),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: mainColumn),
                      SizedBox(width: spacing.lg),
                      SizedBox(width: 320, child: sideColumn),
                    ],
                  )
                else ...[
                  mainColumn,
                  SizedBox(height: spacing.lg),
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
