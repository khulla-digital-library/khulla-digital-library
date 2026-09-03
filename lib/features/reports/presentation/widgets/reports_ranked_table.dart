import 'package:khulla/features/reports/presentation/placeholder/reports_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A ranked report table — most borrowed titles, most active members.
///
/// The share bar beside each row is what makes it a report rather than a
/// list: a title with 128 loans means nothing until you can see it is a
/// third again as popular as the next one.
class ReportsRankedTable extends StatelessWidget {
  const ReportsRankedTable({
    required this.rows,
    required this.nameLabel,
    super.key,
  });

  /// The rows, best first.
  final List<ReportsRankedRow> rows;

  /// What the first column counts — a title, a member.
  final String nameLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final top = rows.isEmpty
        ? 1
        : rows.map((row) => row.loans).reduce((a, b) => a > b ? a : b);

    return AppTable<ReportsRankedRow>(
      items: rows,
      rowHeight: 52,
      columns: [
        AppTableColumn<ReportsRankedRow>(
          id: 'rank',
          label: l10n.reportsColumnRank,
          width: 40,
          cellBuilder: (context, row) => Text(
            '${rows.indexOf(row) + 1}',
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        AppTableColumn<ReportsRankedRow>(
          id: 'name',
          label: nameLabel,
          flex: 4,
          cellBuilder: (context, row) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colors.textHigh,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                row.detail,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        AppTableColumn<ReportsRankedRow>(
          id: 'share',
          label: l10n.reportsColumnShare,
          flex: 3,
          showFrom: FormFactor.expanded,
          cellBuilder: (context, row) => AppProgressBar(
            value: row.loans / top,
            thickness: 6,
          ),
        ),
        AppTableColumn<ReportsRankedRow>(
          id: 'loans',
          label: l10n.reportsColumnLoans,
          width: 80,
          alignment: Alignment.centerRight,
          cellBuilder: (context, row) => Text(
            '${row.loans}',
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.textHigh,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
      compactBuilder: (context, row) => Padding(
        padding: EdgeInsets.only(bottom: context.appSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                row.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodyMedium,
              ),
            ),
            Text(
              '${row.loans}',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
