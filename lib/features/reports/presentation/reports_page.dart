import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/files/save_csv_file.dart';
import 'package:khulla/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:khulla/features/reports/presentation/cubit/reports_state.dart';
import 'package:khulla/features/reports/presentation/reports_summary_x.dart';
import 'package:khulla/features/reports/presentation/saved_reports.dart';
import 'package:khulla/features/reports/presentation/widgets/reports_fines_card.dart';
import 'package:khulla/features/reports/presentation/widgets/reports_ranked_table.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/components/navigation_group.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/models/load_status.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What the library did over a period, and what it holds today.
///
/// The screen answers two different audiences with one layout: the top half
/// is for the librarian deciding what to buy and who to chase, the saved
/// reports at the bottom are for the committee that wants a CSV. Both read
/// the same figures, which is the only way the two ever agree.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.status.hasError) {
          final l10n = context.l10n;
          return AppErrorView(
            message: state.error?.localizedMessage(l10n) ?? '',
            retryLabel: l10n.commonRetry,
            onRetry: () => context.read<ReportsCubit>().load(),
          );
        }
        return _ReportsBoard(state: state);
      },
    );
  }
}

/// The window of time a report covers.
enum ReportPeriod { month, quarter, year }

class _ReportsBoard extends StatelessWidget {
  const _ReportsBoard({required this.state});

  final ReportsState state;

  Future<void> _export(
    BuildContext context,
    ReportsExportKind kind,
    String title,
  ) async {
    final l10n = context.l10n;
    final csv = state.summary!.csvFor(kind, l10n);
    try {
      final saved = await saveCsvFile(
        filename: '${title.toLowerCase().replaceAll(' ', '-')}.csv',
        header: csv.header,
        rows: csv.rows,
      );
      if (saved == null || !context.mounted) return;
      AppToast.success(
        context,
        message: l10n.reportsExportedToast(title),
        description: saved.path,
      );
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final sideBySide = context.formFactor.isAtLeast(FormFactor.expanded);
    final summary = state.summary!;
    final collection = summary.collectionSlices();
    final collectionTotal = collection.fold<double>(
      0,
      (sum, slice) => sum + slice.value,
    );

    final ranked = [
      SectionCard(
        title: l10n.reportsTopTitlesTitle,
        subtitle: l10n.reportsTopTitlesSubtitle,
        child: ReportsRankedTable(
          rows: summary.topTitleRows(),
          nameLabel: l10n.reportsColumnTitle,
        ),
      ),
      SectionCard(
        title: l10n.reportsTopMembersTitle,
        subtitle: l10n.reportsTopMembersSubtitle,
        child: ReportsRankedTable(
          rows: summary.topMemberRows(),
          nameLabel: l10n.reportsColumnMember,
        ),
      ),
    ];

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
                CollectionHeader(
                  title: l10n.reportsHeading,
                  subtitle: l10n.reportsSubtitle,
                  trailing: AppSegmentedControl<ReportPeriod>(
                    value: state.period,
                    items: ReportPeriod.values,
                    itemLabel: (item) => switch (item) {
                      ReportPeriod.month => l10n.commonThisMonth,
                      ReportPeriod.quarter => l10n.commonThisQuarter,
                      ReportPeriod.year => l10n.commonThisYear,
                    },
                    onChanged: (period) =>
                        context.read<ReportsCubit>().changePeriod(period),
                  ),
                ),
                SizedBox(height: spacing.lg),
                AppStatStrip(
                  tiles: [
                    AppStatTile(
                      label: l10n.reportsStatBorrowed,
                      value: '${summary.borrowedCount}',
                      icon: AppIcons.checkOut,
                      tone: AppStatusTone.brand,
                      trend: _trendText(
                        summary.borrowedCount,
                        summary.borrowedPreviousCount,
                      ),
                      trendValue: _trendValue(
                        summary.borrowedCount,
                        summary.borrowedPreviousCount,
                      ),
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatReturned,
                      value: '${summary.returnedCount}',
                      icon: AppIcons.returned,
                      tone: AppStatusTone.success,
                      trend: _trendText(
                        summary.returnedCount,
                        summary.returnedPreviousCount,
                      ),
                      trendValue: _trendValue(
                        summary.returnedCount,
                        summary.returnedPreviousCount,
                      ),
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatNewMembers,
                      value: '${summary.newMembersCount}',
                      icon: AppIcons.addPerson,
                      tone: AppStatusTone.info,
                      trend: _trendText(
                        summary.newMembersCount,
                        summary.newMembersPreviousCount,
                      ),
                      trendValue: _trendValue(
                        summary.newMembersCount,
                        summary.newMembersPreviousCount,
                      ),
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatFines,
                      value: summary.finesRaised.display(),
                      icon: AppIcons.payment,
                      tone: AppStatusTone.warning,
                      trend: _trendText(
                        summary.finesRaised.minorUnits,
                        summary.finesRaisedPrevious.minorUnits,
                      ),
                      trendValue: _trendValue(
                        summary.finesRaised.minorUnits,
                        summary.finesRaisedPrevious.minorUnits,
                      ),
                      trendInverted: true,
                      caption: l10n.commonLastMonth,
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                SectionCard(
                  title: l10n.reportsCirculationTitle,
                  subtitle: l10n.reportsCirculationSubtitle,
                  trailing: Wrap(
                    spacing: spacing.sm,
                    children: [
                      AppLegendDot(
                        label: l10n.reportsStatBorrowed,
                        tone: AppStatusTone.brand,
                        dense: true,
                      ),
                      AppLegendDot(
                        label: l10n.reportsStatReturned,
                        tone: AppStatusTone.success,
                        dense: true,
                      ),
                    ],
                  ),
                  child: AppBarChart(
                    series: summary.circulationSeries(l10n),
                    height: 240,
                  ),
                ),
                SizedBox(height: spacing.md),
                if (sideBySide)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SectionCard(
                            title: l10n.reportsMembersTitle,
                            subtitle: l10n.reportsMembersSubtitle,
                            child: AppLineChart(
                              series: summary.membershipSeries(l10n),
                              showDots: true,
                            ),
                          ),
                        ),
                        SizedBox(width: spacing.md),
                        Expanded(
                          child: _CollectionMixCard(
                            slices: collection,
                            total: collectionTotal,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  SectionCard(
                    title: l10n.reportsMembersTitle,
                    subtitle: l10n.reportsMembersSubtitle,
                    child: AppLineChart(
                      series: summary.membershipSeries(l10n),
                      showDots: true,
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  _CollectionMixCard(
                    slices: collection,
                    total: collectionTotal,
                  ),
                ],
                SizedBox(height: spacing.md),
                ReportsFinesCard(totals: summary.fineTotals(l10n)),
                SizedBox(height: spacing.md),
                if (sideBySide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: ranked.first),
                      SizedBox(width: spacing.md),
                      Expanded(child: ranked.last),
                    ],
                  )
                else ...[
                  ranked.first,
                  SizedBox(height: spacing.md),
                  ranked.last,
                ],
                SizedBox(height: spacing.lg),
                AppSectionHeader(
                  title: l10n.reportsSavedTitle,
                  subtitle: l10n.reportsSavedSubtitle,
                ),
                SizedBox(height: spacing.md),
                NavigationGroup(
                  children: [
                    for (final (index, report) in reportsSaved(l10n).indexed)
                      _SavedReportTile(
                        report: report,
                        onExport: () => unawaited(
                          _export(
                            context,
                            reportsExportKinds[index],
                            report.title,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String? _trendText(int current, int previous) {
  if (previous == 0) return current == 0 ? null : '+100%';
  final change = ((current - previous) / previous) * 100;
  final sign = change >= 0 ? '+' : '';
  return '$sign${change.toStringAsFixed(1)}%';
}

num _trendValue(int current, int previous) {
  if (previous == 0) return current == 0 ? 0 : 100;
  return ((current - previous) / previous) * 100;
}

/// Every catalogued copy by format, as a donut and its legend.
class _CollectionMixCard extends StatelessWidget {
  const _CollectionMixCard({required this.slices, required this.total});

  final List<AppChartPoint> slices;
  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return SectionCard(
      title: l10n.reportsCollectionTitle,
      subtitle: l10n.reportsCollectionSubtitle,
      child: Row(
        children: [
          AppDonutChart(
            slices: slices,
            size: 150,
            thickness: 20,
            centerValue: total.toStringAsFixed(0),
            centerLabel: l10n.dashboardCollectionTotal,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final slice in slices)
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.xs),
                    child: AppLegendDot(
                      label: slice.label,
                      tone: slice.tone ?? AppStatusTone.brand,
                      value: slice.value.toStringAsFixed(0),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One saved report, as a row with its export action.
///
/// A row rather than a card in a grid. Six identical rectangles said the six
/// reports were six different kinds of thing, and putting a tap on the card
/// while also putting a button inside it left no honest answer to what
/// clicking the middle of it should do. A report is a document you export, so
/// the row names it and the verb sits at the end of the line.
class _SavedReportTile extends StatelessWidget {
  const _SavedReportTile({required this.report, required this.onExport});

  final SavedReport report;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final stacked = context.formFactor.isCompact;

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: spacing.xxs / 2),
          child: AppIcon(
            report.icon,
            size: spacing.lg - 4,
            color: report.tone.foreground(context),
          ),
        ),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                report.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textHigh,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                report.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final export = AppButton(
      variant: AppButtonVariant.outline,
      icon: AppIcons.tableView,
      onPressed: onExport,
      child: Text(l10n.commonExportCsv),
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                identity,
                SizedBox(height: spacing.sm),
                export,
              ],
            )
          : Row(
              children: [
                Expanded(child: identity),
                SizedBox(width: spacing.md),
                export,
              ],
            ),
    );
  }
}
