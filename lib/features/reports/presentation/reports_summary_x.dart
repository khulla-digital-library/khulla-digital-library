import 'package:intl/intl.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/reports/domain/models/reports_summary.dart';
import 'package:khulla/features/reports/presentation/saved_reports.dart';
import 'package:khulla/features/reports/presentation/widgets/reports_ranked_table.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

final DateFormat _monthFormat = DateFormat('MMM');

/// Maps a raw [ReportsSummary] to the formatted view models the report's
/// widgets draw — l10n and money formatting happen here, not in the
/// repository, which returns facts.
extension ReportsSummaryX on ReportsSummary {
  List<AppChartSeries> circulationSeries(AppLocalizations l10n) => [
    AppChartSeries(
      name: l10n.reportsStatBorrowed,
      points: [
        for (final entry in circulationBorrowedByMonth)
          AppChartPoint(
            label: _monthFormat.format(entry.month),
            value: entry.count.toDouble(),
          ),
      ],
    ),
    AppChartSeries(
      name: l10n.reportsStatReturned,
      tone: AppStatusTone.success,
      points: [
        for (final entry in circulationReturnedByMonth)
          AppChartPoint(
            label: _monthFormat.format(entry.month),
            value: entry.count.toDouble(),
          ),
      ],
    ),
  ];

  List<AppChartSeries> membershipSeries(AppLocalizations l10n) => [
    AppChartSeries(
      name: l10n.reportsStatNewMembers,
      tone: AppStatusTone.info,
      points: [
        for (final entry in membershipGrowthByMonth)
          AppChartPoint(
            label: _monthFormat.format(entry.month),
            value: entry.count.toDouble(),
          ),
      ],
    ),
  ];

  List<AppChartPoint> collectionSlices() {
    const tones = [
      AppStatusTone.brand,
      AppStatusTone.info,
      AppStatusTone.success,
      AppStatusTone.warning,
      AppStatusTone.neutral,
      AppStatusTone.danger,
    ];
    return [
      for (final (index, format) in collectionByFormat.indexed)
        AppChartPoint(
          label: format.label,
          value: format.count.toDouble(),
          tone: tones[index % tones.length],
        ),
    ];
  }

  List<({String label, Money amount, AppStatusTone tone, double share})>
  fineTotals(AppLocalizations l10n) {
    final raisedMinor = finesRaised.minorUnits;
    double shareOf(Money amount) =>
        raisedMinor == 0 ? 0 : amount.minorUnits / raisedMinor;

    return [
      (
        label: l10n.reportsFinesRaised,
        amount: finesRaised,
        tone: AppStatusTone.warning,
        share: 1,
      ),
      (
        label: l10n.reportsFinesCollected,
        amount: finesCollected,
        tone: AppStatusTone.success,
        share: shareOf(finesCollected),
      ),
      (
        label: l10n.reportsFinesWaived,
        amount: finesWaived,
        tone: AppStatusTone.neutral,
        share: shareOf(finesWaived),
      ),
    ];
  }

  List<ReportsRankedRow> topTitleRows() => [
    for (final ranking in topTitles)
      (name: ranking.name, detail: ranking.detail, loans: ranking.count),
  ];

  List<ReportsRankedRow> topMemberRows() => [
    for (final ranking in topMembers)
      (name: ranking.name, detail: ranking.detail, loans: ranking.count),
  ];

  /// The header and rows a saved-report tile's CSV export writes.
  ({List<String> header, List<List<String>> rows}) csvFor(
    ReportsExportKind kind,
    AppLocalizations l10n,
  ) => switch (kind) {
    ReportsExportKind.circulation => (
      header: [
        l10n.reportsColumnMonth,
        l10n.reportsStatBorrowed,
        l10n.reportsStatReturned,
      ],
      rows: [
        for (var i = 0; i < circulationBorrowedByMonth.length; i++)
          [
            _monthFormat.format(circulationBorrowedByMonth[i].month),
            '${circulationBorrowedByMonth[i].count}',
            if (i < circulationReturnedByMonth.length)
              '${circulationReturnedByMonth[i].count}'
            else
              '0',
          ],
      ],
    ),
    ReportsExportKind.collection => (
      header: [l10n.reportsColumnFormat, l10n.reportsColumnCopies],
      rows: [
        for (final format in collectionByFormat)
          [format.label, '${format.count}'],
      ],
    ),
    ReportsExportKind.members => (
      header: [l10n.reportsColumnMonth, l10n.reportsStatNewMembers],
      rows: [
        for (final entry in membershipGrowthByMonth)
          [_monthFormat.format(entry.month), '${entry.count}'],
      ],
    ),
    ReportsExportKind.fines => (
      header: [l10n.commonStatus, l10n.reportsColumnAmount],
      rows: [
        for (final total in fineTotals(l10n))
          [total.label, total.amount.display()],
      ],
    ),
    ReportsExportKind.overdue => (
      header: [
        l10n.reportsColumnTitle,
        l10n.reportsColumnMember,
        l10n.reportsColumnDueDate,
        l10n.reportsColumnDaysLate,
      ],
      rows: [
        for (final loan in overdueLoans)
          [
            loan.title,
            loan.member,
            DateFormat('d MMM y').format(loan.dueDate),
            '${loan.daysLate}',
          ],
      ],
    ),
    ReportsExportKind.acquisitions => (
      header: [l10n.reportsColumnMonth, l10n.reportsColumnCopies],
      rows: [
        for (final entry in acquisitionsByMonth)
          [_monthFormat.format(entry.month), '${entry.count}'],
      ],
    ),
  };
}
