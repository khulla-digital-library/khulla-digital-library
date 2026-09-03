import 'package:khulla/core/money/money.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_activity_entry.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_attention_item.dart';
import 'package:khulla/features/dashboard/presentation/placeholder/dashboard_ranked_entry.dart';
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
      label: l10n.dashboardStatBorrowed,
      route: Routes.circulation,
      value: '248',
      icon: AppIcons.checkOut,
      tone: AppStatusTone.brand,
      caption: l10n.commonLastWeek,
      trend: '+8.2%',
      trendValue: 8.2,
    ),
    DashboardStat(
      label: l10n.dashboardStatReturned,
      route: Routes.circulationReturn,
      value: '231',
      icon: AppIcons.returned,
      tone: AppStatusTone.success,
      caption: l10n.commonLastWeek,
      trend: '+4.5%',
      trendValue: 4.5,
    ),
    DashboardStat(
      label: l10n.dashboardStatOverdue,
      route: Routes.circulation,
      value: '17',
      icon: AppIcons.error,
      tone: AppStatusTone.danger,
      caption: l10n.commonLastWeek,
      trend: '-5.6%',
      trendValue: -5.6,
      trendInverted: true,
    ),
    DashboardStat(
      label: l10n.dashboardStatFines,
      route: Routes.circulationFines,
      value: finesOutstanding.display(),
      icon: AppIcons.wallet,
      tone: AppStatusTone.warning,
      caption: l10n.commonLastWeek,
      trend: '-2.4%',
      trendValue: -2.4,
      trendInverted: true,
    ),
  ];
}

/// Visits and loans across the week, for the usage chart.
///
/// Two series on one axis, grouped per weekday: the pair answers the question
/// a desk actually asks — did the people who came in borrow anything.
List<AppChartSeries> dashboardUsageSeries(AppLocalizations l10n) => [
  AppChartSeries(
    name: l10n.dashboardUsageVisitors,
    tone: AppStatusTone.neutral,
    points: const [
      AppChartPoint(label: 'Sun', value: 42),
      AppChartPoint(label: 'Mon', value: 78),
      AppChartPoint(label: 'Tue', value: 64),
      AppChartPoint(label: 'Wed', value: 91),
      AppChartPoint(label: 'Thu', value: 73),
      AppChartPoint(label: 'Fri', value: 88),
      AppChartPoint(label: 'Sat', value: 55),
    ],
  ),
  AppChartSeries(
    name: l10n.dashboardUsageLoans,
    points: const [
      AppChartPoint(label: 'Sun', value: 18),
      AppChartPoint(label: 'Mon', value: 44),
      AppChartPoint(label: 'Tue', value: 31),
      AppChartPoint(label: 'Wed', value: 52),
      AppChartPoint(label: 'Thu', value: 38),
      AppChartPoint(label: 'Fri', value: 47),
      AppChartPoint(label: 'Sat', value: 24),
    ],
  ),
];

/// Fines accrued month by month, for the trend line.
List<AppChartSeries> dashboardFinesSeries(AppLocalizations l10n) => [
  AppChartSeries(
    name: l10n.dashboardFinesTitle,
    tone: AppStatusTone.warning,
    points: const [
      AppChartPoint(label: 'Feb', value: 620),
      AppChartPoint(label: 'Mar', value: 810),
      AppChartPoint(label: 'Apr', value: 740),
      AppChartPoint(label: 'May', value: 980),
      AppChartPoint(label: 'Jun', value: 1120),
      AppChartPoint(label: 'Jul', value: 890),
      AppChartPoint(label: 'Aug', value: 1240),
      AppChartPoint(label: 'Sep', value: 1060),
    ],
  ),
];

/// Where every copy in the collection is right now, for the donut.
List<AppChartPoint> dashboardCollectionSlices(AppLocalizations l10n) => [
  AppChartPoint(
    label: l10n.statusAvailable,
    value: 1860,
    tone: AppStatusTone.success,
  ),
  AppChartPoint(
    label: l10n.statusOnLoan,
    value: 486,
    tone: AppStatusTone.brand,
  ),
  AppChartPoint(
    label: l10n.statusReserved,
    value: 124,
    tone: AppStatusTone.info,
  ),
  AppChartPoint(
    label: l10n.statusLost,
    value: 38,
    tone: AppStatusTone.danger,
  ),
];

/// How the catalogue divides by subject, as label/count/share triples.
List<({String label, String count, double share})> dashboardSubjectShares() =>
    const [
      (label: 'Literature', count: '742', share: 0.31),
      (label: 'Science and technology', count: '512', share: 0.21),
      (label: 'History and geography', count: '388', share: 0.16),
      (label: 'Children and young adult', count: '294', share: 0.12),
      (label: 'Nepali language', count: '256', share: 0.11),
      (label: 'Reference', count: '216', share: 0.09),
    ];

/// The last few things that happened at the desk.
List<DashboardActivityEntry> dashboardRecentActivity() => const [
  DashboardActivityEntry(
    kind: DashboardActivityKind.borrow,
    item: 'Palpasa Cafe',
    itemCode: 'BK-10234',
    member: 'Livia Hart',
    memberCode: 'MBR-2081',
    when: 'Today, 09:20',
    due: '11 Oct',
    tone: AppStatusTone.brand,
  ),
  DashboardActivityEntry(
    kind: DashboardActivityKind.returned,
    item: 'Seto Dharti',
    itemCode: 'BK-09876',
    member: 'Ezra Nolan',
    memberCode: 'MBR-1170',
    when: 'Today, 09:05',
    due: null,
    tone: AppStatusTone.success,
  ),
  DashboardActivityEntry(
    kind: DashboardActivityKind.reserved,
    item: 'Karnali Blues',
    itemCode: 'BK-11001',
    member: 'Isla Ray',
    memberCode: 'MBR-2389',
    when: 'Today, 08:44',
    due: null,
    tone: AppStatusTone.info,
  ),
  DashboardActivityEntry(
    kind: DashboardActivityKind.fine,
    item: 'Summer Love',
    itemCode: 'BK-10567',
    member: 'Milo Sharp',
    memberCode: 'MBR-4112',
    when: 'Yesterday, 17:40',
    due: null,
    tone: AppStatusTone.danger,
  ),
  DashboardActivityEntry(
    kind: DashboardActivityKind.borrow,
    item: 'Muna Madan',
    itemCode: 'BK-11122',
    member: 'Ava Lin',
    memberCode: 'MBR-3021',
    when: 'Yesterday, 16:02',
    due: '09 Oct',
    tone: AppStatusTone.brand,
  ),
  DashboardActivityEntry(
    kind: DashboardActivityKind.returned,
    item: 'Radha',
    itemCode: 'BK-10345',
    member: 'Julian Cross',
    memberCode: 'MBR-2759',
    when: 'Yesterday, 15:18',
    due: null,
    tone: AppStatusTone.success,
  ),
];

/// The titles the library cannot keep on the shelf.
List<DashboardRankedEntry> dashboardTopTitles(AppLocalizations l10n) => [
  DashboardRankedEntry(
    name: 'Palpasa Cafe',
    detail: 'Narayan Wagle',
    figure: l10n.dashboardBorrowCount('128'),
  ),
  DashboardRankedEntry(
    name: 'Seto Dharti',
    detail: 'Amar Neupane',
    figure: l10n.dashboardBorrowCount('113'),
  ),
  DashboardRankedEntry(
    name: 'Karnali Blues',
    detail: 'Buddhisagar',
    figure: l10n.dashboardBorrowCount('97'),
  ),
  DashboardRankedEntry(
    name: 'Muna Madan',
    detail: 'Laxmi Prasad Devkota',
    figure: l10n.dashboardBorrowCount('86'),
  ),
];

/// The members who use the library most.
List<DashboardRankedEntry> dashboardTopMembers(AppLocalizations l10n) => [
  DashboardRankedEntry(
    name: 'Livia Hart',
    detail: 'MBR-2081',
    figure: l10n.dashboardBorrowCount('42'),
  ),
  DashboardRankedEntry(
    name: 'Ezra Nolan',
    detail: 'MBR-1170',
    figure: l10n.dashboardBorrowCount('39'),
  ),
  DashboardRankedEntry(
    name: 'Isla Ray',
    detail: 'MBR-2389',
    figure: l10n.dashboardBorrowCount('37'),
  ),
  DashboardRankedEntry(
    name: 'Milo Sharp',
    detail: 'MBR-4112',
    figure: l10n.dashboardBorrowCount('31'),
  ),
];

/// What the desk has to work through today.
List<DashboardAttentionItem> dashboardAttentionItems(AppLocalizations l10n) => [
  DashboardAttentionItem(
    label: l10n.dashboardAttentionOverdue,
    count: '17',
    icon: AppIcons.error,
    tone: AppStatusTone.danger,
    route: Routes.circulation,
  ),
  DashboardAttentionItem(
    label: l10n.dashboardAttentionHolds,
    count: '6',
    icon: AppIcons.bookmark,
    tone: AppStatusTone.info,
    route: Routes.circulationReservations,
  ),
  DashboardAttentionItem(
    label: l10n.dashboardAttentionExpiring,
    count: '12',
    icon: AppIcons.clock,
    tone: AppStatusTone.warning,
    route: Routes.members,
  ),
  DashboardAttentionItem(
    label: l10n.dashboardAttentionDamaged,
    count: '3',
    icon: AppIcons.damage,
    tone: AppStatusTone.neutral,
    route: Routes.catalogCopies,
  ),
];
