import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_placeholder.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_activity_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_attention_section.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_quick_actions.dart';
import 'package:khulla/features/dashboard/presentation/widgets/dashboard_stats_grid.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The shell's landing tab: what the library looks like right now.
///
/// It is the app's one *wide* page — [AppPageBody] caps it at the dense
/// content width rather than the reading width, because a board of tiles and
/// two side-by-side sections is exactly the content a desktop window is for.
///
/// The board is a single [CustomScrollView]. Each section is a sliver, so the
/// page scrolls as one surface and no section nests a scrollable inside
/// another — the rule that keeps a ten-thousand-title catalogue openable
/// applies here too, even while every section is still a placeholder.
///
/// Every section is blank on purpose. The layout, the breakpoints and the
/// empty copy are settled now so that building circulation is a matter of
/// dropping a cubit behind a section, not redesigning the page around it.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final formFactor = context.formFactor;
    final twoPane = formFactor.isAtLeast(FormFactor.expanded);

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
                const DashboardHeader(),
                SizedBox(height: spacing.lg),
                DashboardStatsGrid(stats: dashboardPlaceholderStats(l10n)),
                SizedBox(height: spacing.lg),
                if (twoPane)
                  const IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: DashboardActivitySection()),
                        _PaneGap(),
                        Expanded(flex: 2, child: DashboardAttentionSection()),
                      ],
                    ),
                  )
                else ...[
                  const DashboardActivitySection(),
                  SizedBox(height: spacing.md),
                  const DashboardAttentionSection(),
                ],
                SizedBox(height: spacing.lg),
                AppSectionHeader(
                  title: l10n.dashboardQuickActionsTitle,
                  subtitle: l10n.dashboardQuickActionsSubtitle,
                ),
                SizedBox(height: spacing.md),
                const DashboardQuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The gap between the two board panes, as a widget so the surrounding [Row]
/// can stay `const`.
class _PaneGap extends StatelessWidget {
  const _PaneGap();

  @override
  Widget build(BuildContext context) => SizedBox(width: context.appSpacing.md);
}
