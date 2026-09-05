import 'package:khulla/features/circulation/fine/domain/models/fine.dart';
import 'package:khulla/features/circulation/fine/presentation/cubit/fine_list_cubit.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/features/members/presentation/cubit/member_detail_cubit.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What a member owes, and the control that settles it.
///
/// Outstanding amounts come from [FineListCubit] on the ledger page and from
/// [MemberDetailCubit] here. [onCollect] is passed down because payment
/// recording is not wired yet — the page shows the dialog, then toasts.
class MemberFinesCard extends StatelessWidget {
  const MemberFinesCard({
    required this.fines,
    required this.onCollect,
    super.key,
  });

  final List<Fine> fines;
  final void Function(Fine fine) onCollect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.memberDetailFinesTitle,
      subtitle: l10n.memberDetailFinesSubtitle,
      child: fines.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.memberDetailFinesEmptyTitle,
              message: l10n.memberDetailFinesEmptyBody,
            )
          : AppTable<Fine>(
              items: fines,
              columns: [
                AppTableColumn<Fine>(
                  id: 'title',
                  label: l10n.finesColumnTitle,
                  flex: 4,
                  cellBuilder: (context, fine) =>
                      Text(fine.titleName ?? l10n.commonNotSet),
                ),
                AppTableColumn<Fine>(
                  id: 'raised',
                  label: l10n.finesColumnRaised,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, fine) => Text(
                    fine.raisedOn,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<Fine>(
                  id: 'amount',
                  label: l10n.finesColumnAmount,
                  width: 110,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, fine) => Text(
                    fine.outstanding.display(),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AppTableColumn<Fine>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 120,
                  cellBuilder: (context, fine) => AppStatusBadge(
                    dense: true,
                    label: fine.status.label(l10n),
                    tone: fine.status.tone,
                  ),
                ),
                AppTableColumn<Fine>(
                  id: 'actions',
                  label: l10n.commonActions,
                  width: 100,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, fine) => AppTextButton(
                    onPressed: () => onCollect(fine),
                    child: Text(l10n.finesCollect),
                  ),
                ),
              ],
            ),
    );
  }
}
