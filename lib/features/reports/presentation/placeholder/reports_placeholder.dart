import 'package:khulla/core/money/money.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Sample figures for the reports screen until the tables exist.
///
/// They are here rather than in the widgets so the swap is one deletion: when
/// the queries land, the page reads them from a cubit and this file goes.

/// Loans issued against copies returned, month by month.
List<AppChartSeries> reportsCirculationSeries(AppLocalizations l10n) => [
  AppChartSeries(
    name: l10n.reportsStatBorrowed,
    points: const [
      AppChartPoint(label: 'Feb', value: 620),
      AppChartPoint(label: 'Mar', value: 705),
      AppChartPoint(label: 'Apr', value: 688),
      AppChartPoint(label: 'May', value: 742),
      AppChartPoint(label: 'Jun', value: 815),
      AppChartPoint(label: 'Jul', value: 690),
      AppChartPoint(label: 'Aug', value: 872),
      AppChartPoint(label: 'Sep', value: 934),
    ],
  ),
  AppChartSeries(
    name: l10n.reportsStatReturned,
    tone: AppStatusTone.success,
    points: const [
      AppChartPoint(label: 'Feb', value: 598),
      AppChartPoint(label: 'Mar', value: 690),
      AppChartPoint(label: 'Apr', value: 671),
      AppChartPoint(label: 'May', value: 719),
      AppChartPoint(label: 'Jun', value: 780),
      AppChartPoint(label: 'Jul', value: 676),
      AppChartPoint(label: 'Aug', value: 840),
      AppChartPoint(label: 'Sep', value: 901),
    ],
  ),
];

/// Members joining, month by month.
List<AppChartSeries> reportsMembershipSeries(AppLocalizations l10n) => [
  AppChartSeries(
    name: l10n.reportsStatNewMembers,
    tone: AppStatusTone.info,
    points: const [
      AppChartPoint(label: 'Feb', value: 18),
      AppChartPoint(label: 'Mar', value: 26),
      AppChartPoint(label: 'Apr', value: 22),
      AppChartPoint(label: 'May', value: 34),
      AppChartPoint(label: 'Jun', value: 41),
      AppChartPoint(label: 'Jul', value: 29),
      AppChartPoint(label: 'Aug', value: 46),
      AppChartPoint(label: 'Sep', value: 52),
    ],
  ),
];

/// Every catalogued copy by format.
List<AppChartPoint> reportsCollectionSlices(AppLocalizations l10n) => [
  AppChartPoint(
    label: l10n.formatBook,
    value: 1840,
    tone: AppStatusTone.brand,
  ),
  AppChartPoint(
    label: l10n.formatJournal,
    value: 320,
    tone: AppStatusTone.info,
  ),
  AppChartPoint(
    label: l10n.formatMagazine,
    value: 214,
    tone: AppStatusTone.success,
  ),
  AppChartPoint(
    label: l10n.formatAudio,
    value: 96,
    tone: AppStatusTone.warning,
  ),
  AppChartPoint(
    label: l10n.formatDigital,
    value: 62,
    tone: AppStatusTone.neutral,
  ),
];

/// Fines raised, collected and waived over the period.
List<({String label, Money amount, AppStatusTone tone, double share})>
reportsFineTotals(AppLocalizations l10n) => [
  (
    label: l10n.reportsFinesRaised,
    amount: Money.major(4820),
    tone: AppStatusTone.warning,
    share: 1,
  ),
  (
    label: l10n.reportsFinesCollected,
    amount: Money.major(3160),
    tone: AppStatusTone.success,
    share: 0.65,
  ),
  (
    label: l10n.reportsFinesWaived,
    amount: Money.major(740),
    tone: AppStatusTone.neutral,
    share: 0.15,
  ),
];

/// One row of a ranked report table.
typedef ReportsRankedRow = ({String name, String detail, int loans});

/// The titles borrowed most over the period.
List<ReportsRankedRow> reportsTopTitles() => const [
  (name: 'Palpasa Cafe', detail: 'Narayan Wagle', loans: 128),
  (name: 'Seto Dharti', detail: 'Amar Neupane', loans: 113),
  (name: 'Karnali Blues', detail: 'Buddhisagar', loans: 97),
  (name: 'Muna Madan', detail: 'Laxmi Prasad Devkota', loans: 86),
  (name: 'Summer Love', detail: 'Subin Bhattarai', loans: 74),
];

/// The members who borrowed most over the period.
List<ReportsRankedRow> reportsTopMembers() => const [
  (name: 'Livia Hart', detail: 'MBR-2081', loans: 42),
  (name: 'Ezra Nolan', detail: 'MBR-1170', loans: 39),
  (name: 'Isla Ray', detail: 'MBR-2389', loans: 37),
  (name: 'Milo Sharp', detail: 'MBR-4112', loans: 31),
  (name: 'Ava Lin', detail: 'MBR-3021', loans: 28),
];

/// One report a committee or a council asks for.
class SavedReport {
  const SavedReport({
    required this.title,
    required this.body,
    required this.icon,
    required this.tone,
  });

  /// What the report is called.
  final String title;

  /// What it contains.
  final String body;

  /// The tile's glyph.
  final AppIconSpec icon;

  /// The tile's tone.
  final AppStatusTone tone;
}

/// The reports that can be exported as they stand.
List<SavedReport> reportsSaved(AppLocalizations l10n) => [
  SavedReport(
    title: l10n.reportsSavedCirculation,
    body: l10n.reportsSavedCirculationBody,
    icon: AppIcons.transfer,
    tone: AppStatusTone.brand,
  ),
  SavedReport(
    title: l10n.reportsSavedCollection,
    body: l10n.reportsSavedCollectionBody,
    icon: AppIcons.inventory,
    tone: AppStatusTone.info,
  ),
  SavedReport(
    title: l10n.reportsSavedMembers,
    body: l10n.reportsSavedMembersBody,
    icon: AppIcons.people,
    tone: AppStatusTone.success,
  ),
  SavedReport(
    title: l10n.reportsSavedFines,
    body: l10n.reportsSavedFinesBody,
    icon: AppIcons.wallet,
    tone: AppStatusTone.warning,
  ),
  SavedReport(
    title: l10n.reportsSavedOverdue,
    body: l10n.reportsSavedOverdueBody,
    icon: AppIcons.error,
    tone: AppStatusTone.danger,
  ),
  SavedReport(
    title: l10n.reportsSavedAcquisitions,
    body: l10n.reportsSavedAcquisitionsBody,
    icon: AppIcons.delivery,
    tone: AppStatusTone.neutral,
  ),
];
