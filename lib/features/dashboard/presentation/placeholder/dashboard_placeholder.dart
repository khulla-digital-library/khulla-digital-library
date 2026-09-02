import 'package:khulla/core/money/money.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_stat.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Stand-in figures for the dashboard until the catalogue tables exist.
///
/// They are here rather than in the widgets so the swap is one deletion: when
/// `DashboardCubit` lands, the page reads `state.stats` instead of calling
/// this, and this file goes.
///
/// The list is `final`, not `const` — [Money.major] is not a const
/// constructor, and a paisa literal written for constness would be a worse
/// trade than a runtime list of six items.
List<DashboardStat> dashboardPlaceholderStats(AppLocalizations l10n) {
  final finesOutstanding = Money.major(1240.50);

  return [
    DashboardStat(
      label: l10n.dashboardStatTitles,
      route: Routes.catalogTitles,
      value: '1,204',
      icon: Icons.menu_book_rounded,
      caption: l10n.dashboardStatPlaceholder,
    ),
    DashboardStat(
      label: l10n.dashboardStatOnLoan,
      route: Routes.circulation,
      value: '86',
      icon: Icons.swap_horiz_rounded,
      tone: AppStatusTone.brand,
      caption: l10n.dashboardStatPlaceholder,
    ),
    DashboardStat(
      label: l10n.dashboardStatDueToday,
      route: Routes.circulation,
      value: '12',
      icon: Icons.event_rounded,
      tone: AppStatusTone.warning,
      caption: l10n.dashboardStatPlaceholder,
    ),
    DashboardStat(
      label: l10n.dashboardStatOverdue,
      route: Routes.circulation,
      value: '5',
      icon: Icons.error_outline_rounded,
      tone: AppStatusTone.danger,
      caption: l10n.dashboardStatPlaceholder,
    ),
    DashboardStat(
      label: l10n.dashboardStatMembers,
      route: Routes.members,
      value: '312',
      icon: Icons.people_rounded,
      tone: AppStatusTone.success,
      caption: l10n.dashboardStatPlaceholder,
    ),
    DashboardStat(
      label: l10n.dashboardStatFines,
      route: Routes.circulationFines,
      value: finesOutstanding.display(),
      icon: Icons.account_balance_wallet_rounded,
      tone: AppStatusTone.info,
      caption: l10n.dashboardStatPlaceholder,
    ),
  ];
}
