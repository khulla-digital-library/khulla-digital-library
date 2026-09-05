import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The copies a member is holding, or everything they have brought back.
class MemberLoansCard extends StatelessWidget {
  const MemberLoansCard({
    required this.title,
    required this.subtitle,
    required this.loans,
    required this.emptyTitle,
    required this.emptyBody,
    this.isHistory = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Loan> loans;
  final String emptyTitle;
  final String emptyBody;
  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return SectionCard(
      title: title,
      subtitle: subtitle,
      child: loans.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: emptyTitle,
              message: emptyBody,
            )
          : AppTable<Loan>(
              items: loans,
              columns: [
                AppTableColumn<Loan>(
                  id: 'title',
                  label: l10n.loansColumnTitle,
                  flex: 4,
                  cellBuilder: (context, loan) =>
                      Text(loan.titleName ?? l10n.commonNotSet),
                ),
                AppTableColumn<Loan>(
                  id: 'barcode',
                  label: l10n.loansColumnBarcode,
                  flex: 2,
                  showFrom: FormFactor.large,
                  cellBuilder: (context, loan) =>
                      Text(loan.barcode ?? l10n.commonNotSet, style: muted),
                ),
                AppTableColumn<Loan>(
                  id: 'issued',
                  label: l10n.loansColumnIssued,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, loan) =>
                      Text(loan.issuedOn, style: muted),
                ),
                AppTableColumn<Loan>(
                  id: 'due',
                  label: l10n.loansColumnDue,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, loan) => Text(
                    isHistory
                        ? (loan.returnedAt == null
                              ? loan.dueOn
                              : AppDateFormat.format(loan.returnedAt!))
                        : loan.dueOn,
                  ),
                ),
                AppTableColumn<Loan>(
                  id: 'fine',
                  label: l10n.loansColumnFine,
                  width: 100,
                  alignment: Alignment.centerRight,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, loan) {
                    final fine = isHistory
                        ? loan.accruedFine
                        : loan.accruedFine;
                    return Text(
                      fine.isZero ? l10n.commonNotSet : fine.display(),
                      style: fine.isZero
                          ? muted
                          : context.textTheme.bodyMedium?.copyWith(
                              color: scheme.error,
                            ),
                    );
                  },
                ),
                AppTableColumn<Loan>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 120,
                  cellBuilder: (context, loan) {
                    final status = isHistory ? loan.status : loan.status;
                    return AppStatusBadge(
                      dense: true,
                      label: status.label(l10n),
                      tone: status.tone,
                    );
                  },
                ),
              ],
            ),
    );
  }
}
