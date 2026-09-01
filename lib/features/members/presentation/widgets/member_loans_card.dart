import 'package:khulla/features/members/presentation/placeholder/member_activity.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The copies a member is holding, or everything they have brought back.
///
/// One widget for both because the two tables differ only in which date
/// matters — the due date while a copy is out, the return date once it is
/// back — and duplicating the column list to say that would be worse.
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
  final List<MemberLoanEntry> loans;
  final String emptyTitle;
  final String emptyBody;

  /// Whether these are past loans, which show a return date and no action.
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
      icon: isHistory ? Icons.history_rounded : Icons.swap_horiz_rounded,
      child: loans.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: emptyTitle,
              message: emptyBody,
            )
          : AppTable<MemberLoanEntry>(
              items: loans,
              columns: [
                AppTableColumn<MemberLoanEntry>(
                  id: 'title',
                  label: l10n.loansColumnTitle,
                  flex: 4,
                  cellBuilder: (context, loan) => Text(loan.titleName),
                ),
                AppTableColumn<MemberLoanEntry>(
                  id: 'barcode',
                  label: l10n.loansColumnBarcode,
                  flex: 2,
                  showFrom: FormFactor.large,
                  cellBuilder: (context, loan) =>
                      Text(loan.barcode, style: muted),
                ),
                AppTableColumn<MemberLoanEntry>(
                  id: 'issued',
                  label: l10n.loansColumnIssued,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, loan) =>
                      Text(loan.issued, style: muted),
                ),
                AppTableColumn<MemberLoanEntry>(
                  id: 'due',
                  label: l10n.loansColumnDue,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, loan) => Text(
                    isHistory ? (loan.returned ?? loan.due) : loan.due,
                  ),
                ),
                AppTableColumn<MemberLoanEntry>(
                  id: 'fine',
                  label: l10n.loansColumnFine,
                  width: 100,
                  alignment: Alignment.centerRight,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, loan) => Text(
                    loan.fine.isZero ? l10n.commonNotSet : loan.fine.display(),
                    style: loan.fine.isZero
                        ? muted
                        : context.textTheme.bodyMedium?.copyWith(
                            color: scheme.error,
                          ),
                  ),
                ),
                AppTableColumn<MemberLoanEntry>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 120,
                  cellBuilder: (context, loan) => AppStatusBadge(
                    dense: true,
                    label: isHistory
                        ? l10n.statusReturned
                        : (loan.isOverdue
                              ? l10n.statusOverdue
                              : l10n.statusOnLoan),
                    tone: isHistory
                        ? (loan.isOverdue
                              ? AppStatusTone.warning
                              : AppStatusTone.success)
                        : (loan.isOverdue
                              ? AppStatusTone.danger
                              : AppStatusTone.brand),
                  ),
                ),
              ],
            ),
    );
  }
}
