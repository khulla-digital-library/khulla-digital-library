import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/reports/presentation/placeholder/reports_placeholder.dart';
import 'package:khulla/features/reports/presentation/widgets/reports_fines_card.dart';
import 'package:khulla/features/reports/presentation/widgets/reports_ranked_table.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What the library did over a period, and what it holds today.
///
/// The screen answers two different audiences with one layout: the top half
/// is for the librarian deciding what to buy and who to chase, the saved
/// reports at the bottom are for the committee that wants a PDF. Both read
/// the same figures, which is the only way the two ever agree.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

/// The window of time a report covers.
enum ReportPeriod { month, quarter, year }

class _ReportsPageState extends State<ReportsPage> {
  ReportPeriod _period = ReportPeriod.month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final sideBySide = context.formFactor.isAtLeast(FormFactor.expanded);
    final collection = reportsCollectionSlices(l10n);
    final collectionTotal = collection.fold<double>(
      0,
      (sum, slice) => sum + slice.value,
    );

    final ranked = [
      SectionCard(
        title: l10n.reportsTopTitlesTitle,
        subtitle: l10n.reportsTopTitlesSubtitle,
        icon: Icons.local_fire_department_outlined,
        child: ReportsRankedTable(
          rows: reportsTopTitles(),
          nameLabel: l10n.reportsColumnTitle,
        ),
      ),
      SectionCard(
        title: l10n.reportsTopMembersTitle,
        subtitle: l10n.reportsTopMembersSubtitle,
        icon: Icons.emoji_events_outlined,
        child: ReportsRankedTable(
          rows: reportsTopMembers(),
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
                  actionLabel: l10n.commonExportPdf,
                  actionIcon: Icons.picture_as_pdf_outlined,
                  onAction: () => showNotWiredToast(context),
                  menuTooltip: l10n.commonMoreActions,
                  menuActions: [
                    AppMenuAction(
                      label: l10n.commonExportCsv,
                      icon: Icons.file_download_outlined,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.commonPrint,
                      icon: Icons.print_outlined,
                      onSelected: () => showNotWiredToast(context),
                    ),
                  ],
                  trailing: AppSegmentedControl<ReportPeriod>(
                    value: _period,
                    items: ReportPeriod.values,
                    itemLabel: (item) => switch (item) {
                      ReportPeriod.month => l10n.commonThisMonth,
                      ReportPeriod.quarter => l10n.commonThisQuarter,
                      ReportPeriod.year => l10n.commonThisYear,
                    },
                    onChanged: (period) => setState(() => _period = period),
                  ),
                ),
                SizedBox(height: spacing.lg),
                AppResponsiveGrid(
                  children: [
                    AppStatTile(
                      label: l10n.reportsStatBorrowed,
                      value: '934',
                      icon: Icons.outbound_outlined,
                      tone: AppStatusTone.brand,
                      trend: '+7.1%',
                      trendValue: 7.1,
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatReturned,
                      value: '901',
                      icon: Icons.assignment_turned_in_outlined,
                      tone: AppStatusTone.success,
                      trend: '+6.4%',
                      trendValue: 6.4,
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatNewMembers,
                      value: '52',
                      icon: Icons.person_add_alt_1_outlined,
                      tone: AppStatusTone.info,
                      trend: '+13%',
                      trendValue: 13,
                      caption: l10n.commonLastMonth,
                    ),
                    AppStatTile(
                      label: l10n.reportsStatFines,
                      value: Money.major(3160).display(),
                      icon: Icons.payments_outlined,
                      tone: AppStatusTone.warning,
                      trend: '-3.2%',
                      trendValue: -3.2,
                      caption: l10n.commonLastMonth,
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                SectionCard(
                  title: l10n.reportsCirculationTitle,
                  subtitle: l10n.reportsCirculationSubtitle,
                  icon: Icons.stacked_bar_chart_rounded,
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
                    series: reportsCirculationSeries(l10n),
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
                            icon: Icons.show_chart_rounded,
                            child: AppLineChart(
                              series: reportsMembershipSeries(l10n),
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
                    icon: Icons.show_chart_rounded,
                    child: AppLineChart(
                      series: reportsMembershipSeries(l10n),
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
                const ReportsFinesCard(),
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
                  icon: Icons.folder_copy_outlined,
                ),
                SizedBox(height: spacing.md),
                AppResponsiveGrid(
                  largeColumns: 3,
                  children: [
                    for (final report in reportsSaved(l10n))
                      _SavedReportTile(report: report),
                  ],
                ),
                SizedBox(height: spacing.md),
                Text(
                  l10n.reportsPlaceholderNote,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.appColors.textMuted,
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
      icon: Icons.donut_large_rounded,
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

/// One saved report, ready to export.
class _SavedReportTile extends StatelessWidget {
  const _SavedReportTile({required this.report});

  final SavedReport report;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return AppCard(
      onTap: () => showNotWiredToast(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: report.tone.background(context),
                  borderRadius: BorderRadius.circular(context.appRadius.tile),
                ),
                child: Padding(
                  padding: EdgeInsets.all(spacing.xs),
                  child: Icon(
                    report.icon,
                    size: spacing.md + 2,
                    color: report.tone.foreground(context),
                  ),
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  report.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: colors.textHigh,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Text(
            report.body,
            maxLines: 3,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
              height: 1.4,
            ),
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              AppButton(
                size: AppButtonSize.small,
                variant: AppButtonVariant.outline,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () => showNotWiredToast(context),
                child: Text(l10n.commonExportPdf),
              ),
              SizedBox(width: spacing.xs),
              AppButton(
                size: AppButtonSize.small,
                variant: AppButtonVariant.outline,
                icon: Icons.table_view_outlined,
                onPressed: () => showNotWiredToast(context),
                child: Text(l10n.commonExportCsv),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
