import 'package:khulla/features/members/presentation/placeholder/member_fine_entry.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What a member owes, and the control that settles it.
class MemberFinesCard extends StatelessWidget {
  const MemberFinesCard({
    required this.fines,
    required this.onCollect,
    super.key,
  });

  final List<MemberFineEntry> fines;
  final void Function(MemberFineEntry fine) onCollect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.memberDetailFinesTitle,
      subtitle: l10n.memberDetailFinesSubtitle,
      icon: Icons.account_balance_wallet_outlined,
      child: fines.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.memberDetailFinesEmptyTitle,
              message: l10n.memberDetailFinesEmptyBody,
            )
          : AppTable<MemberFineEntry>(
              items: fines,
              columns: [
                AppTableColumn<MemberFineEntry>(
                  id: 'title',
                  label: l10n.finesColumnTitle,
                  flex: 4,
                  cellBuilder: (context, fine) =>
                      Text(fine.titleName ?? l10n.commonNotSet),
                ),
                AppTableColumn<MemberFineEntry>(
                  id: 'raised',
                  label: l10n.finesColumnRaised,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, fine) => Text(
                    fine.raised,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<MemberFineEntry>(
                  id: 'amount',
                  label: l10n.finesColumnAmount,
                  width: 110,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, fine) => Text(
                    fine.amount.display(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: fine.isPaid ? scheme.onSurface : scheme.error,
                    ),
                  ),
                ),
                AppTableColumn<MemberFineEntry>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 110,
                  cellBuilder: (context, fine) => AppStatusBadge(
                    dense: true,
                    label: fine.isPaid
                        ? l10n.finesStatusPaid
                        : l10n.finesStatusUnpaid,
                    tone: fine.isPaid
                        ? AppStatusTone.success
                        : AppStatusTone.danger,
                  ),
                ),
                AppTableColumn<MemberFineEntry>(
                  id: 'collect',
                  label: l10n.commonActions,
                  width: 56,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, fine) => AppIconButton(
                    icon: Icons.payments_outlined,
                    tooltip: l10n.finesCollect,
                    onPressed: fine.isPaid ? null : () => onCollect(fine),
                  ),
                ),
              ],
            ),
    );
  }
}
