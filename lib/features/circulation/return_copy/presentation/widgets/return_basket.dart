import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/loan_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The copies coming back, with what each one costs.
///
/// The fine is priced as the copy is added rather than at the end: a member
/// standing at the desk should hear the number when the book lands on it, not
/// after the last one is scanned.
class ReturnBasket extends StatelessWidget {
  const ReturnBasket({
    required this.loans,
    required this.scanController,
    required this.onScanSubmitted,
    required this.onRemove,
    super.key,
  });

  final List<LoanRecord> loans;
  final TextEditingController scanController;
  final ValueChanged<String> onScanSubmitted;
  final void Function(LoanRecord loan) onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.returnsListSection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: scanController,
            hintText: l10n.returnsScanHint,
            prefixIcon: AppIcon(
              AppIcons.scan,
              size: context.appMetrics.icon,
              color: scheme.onSurfaceVariant,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: onScanSubmitted,
            onChanged: (_) {},
          ),
          SizedBox(height: spacing.md),
          if (loans.isEmpty)
            AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.returnsEmptyTitle,
              message: l10n.returnsEmptyBody,
            )
          else
            AppTable<LoanRecord>(
              items: loans,
              columns: [
                AppTableColumn<LoanRecord>(
                  id: 'title',
                  label: l10n.loansColumnTitle,
                  flex: 4,
                  cellBuilder: (context, loan) => Text(loan.titleName),
                ),
                AppTableColumn<LoanRecord>(
                  id: 'member',
                  label: l10n.loansColumnMember,
                  flex: 3,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, loan) => Text(
                    loan.memberName,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<LoanRecord>(
                  id: 'daysLate',
                  label: l10n.returnsColumnDaysLate,
                  width: 100,
                  alignment: Alignment.centerRight,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, loan) => Text(
                    loan.daysLate == 0 ? l10n.commonNotSet : '${loan.daysLate}',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: loan.daysLate == 0
                          ? scheme.onSurfaceVariant
                          : scheme.error,
                    ),
                  ),
                ),
                AppTableColumn<LoanRecord>(
                  id: 'fine',
                  label: l10n.returnsColumnFine,
                  width: 110,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, loan) => Text(
                    loan.accruedFine.isZero
                        ? l10n.commonNotSet
                        : loan.accruedFine.display(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: loan.accruedFine.isZero
                          ? scheme.onSurfaceVariant
                          : scheme.error,
                      fontWeight: loan.accruedFine.isZero
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
                AppTableColumn<LoanRecord>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 120,
                  showFrom: FormFactor.large,
                  cellBuilder: (context, loan) => AppStatusBadge(
                    dense: true,
                    label: loan.status.label(l10n),
                    tone: loan.status.tone,
                  ),
                ),
                AppTableColumn<LoanRecord>(
                  id: 'remove',
                  label: l10n.commonActions,
                  width: 56,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, loan) => AppIconButton(
                    icon: AppIcons.close,
                    tooltip: l10n.returnsRemoveCopy,
                    tone: AppStatusTone.danger,
                    onPressed: () => onRemove(loan),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
