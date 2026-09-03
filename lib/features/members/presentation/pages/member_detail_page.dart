import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/features/members/presentation/placeholder/members_placeholder.dart';
import 'package:khulla/features/members/presentation/widgets/member_detail_header.dart';
import 'package:khulla/features/members/presentation/widgets/member_fines_card.dart';
import 'package:khulla/features/members/presentation/widgets/member_loans_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One borrower's record: their standing, what they are holding, what they
/// owe, and everything they have read.
///
/// The four figures at the top are the ones a desk decides on — copies out,
/// how many are late, what is owed, and how much they have borrowed over the
/// life of the card.
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({required this.memberId, super.key});

  /// The record to show, taken from the route.
  final String memberId;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.memberDetailDeleteTitle,
      message: l10n.memberDetailDeleteBody,
      confirmLabel: l10n.memberDetailDelete,
      cancelLabel: l10n.commonCancel,
    );
    if (!context.mounted || !confirmed) return;
    showNotWiredToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final member = placeholderMemberById(memberId);
    final twoPane = context.formFactor.isAtLeast(FormFactor.expanded);

    final loansCard = MemberLoansCard(
      title: l10n.memberDetailLoansTitle,
      subtitle: l10n.memberDetailLoansSubtitle,
      loans: placeholderMemberLoans,
      emptyTitle: l10n.memberDetailLoansEmptyTitle,
      emptyBody: l10n.memberDetailLoansEmptyBody,
    );
    final historyCard = MemberLoansCard(
      title: l10n.memberDetailHistoryTitle,
      subtitle: l10n.memberDetailHistorySubtitle,
      loans: placeholderMemberHistory,
      emptyTitle: l10n.memberDetailHistoryEmptyTitle,
      emptyBody: l10n.memberDetailHistoryEmptyBody,
      isHistory: true,
    );
    final finesCard = MemberFinesCard(
      fines: placeholderMemberFines,
      onCollect: (_) => showNotWiredToast(context),
    );
    final detailsCard = _MemberDetailsCard(memberId: memberId);

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
                MemberDetailHeader(
                  member: member,
                  onCheckOut: () => context.go(Routes.circulationCheckOut),
                  menuActions: [
                    AppMenuAction(
                      label: l10n.memberDetailEdit,
                      icon: AppIcons.edit,
                      onSelected: () =>
                          MemberFormDialog.show(context, memberId: memberId),
                    ),
                    AppMenuAction(
                      label: l10n.memberDetailRenewMembership,
                      icon: AppIcons.renew,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.memberDetailSuspend,
                      icon: AppIcons.blocked,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.memberDetailDelete,
                      icon: AppIcons.delete,
                      isDestructive: true,
                      onSelected: () => unawaited(_confirmDelete(context)),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                AppStatStrip(
                  tiles: [
                    AppStatTile(
                      label: l10n.memberDetailStatLoans,
                      value: '${member.loansOut}',
                      icon: AppIcons.transfer,
                      tone: AppStatusTone.brand,
                    ),
                    AppStatTile(
                      label: l10n.memberDetailStatOverdue,
                      value: '${member.overdue}',
                      icon: AppIcons.error,
                      tone: member.overdue > 0
                          ? AppStatusTone.danger
                          : AppStatusTone.neutral,
                    ),
                    AppStatTile(
                      label: l10n.memberDetailStatFines,
                      value: member.finesOwed.display(),
                      icon: AppIcons.wallet,
                      tone: member.finesOwed.isPositive
                          ? AppStatusTone.danger
                          : AppStatusTone.neutral,
                    ),
                    AppStatTile(
                      label: l10n.memberDetailStatBorrowed,
                      value: '${member.borrowedAllTime}',
                      icon: AppIcons.book,
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            loansCard,
                            SizedBox(height: spacing.md),
                            finesCard,
                            SizedBox(height: spacing.md),
                            historyCard,
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(flex: 2, child: detailsCard),
                    ],
                  )
                else ...[
                  detailsCard,
                  SizedBox(height: spacing.md),
                  loansCard,
                  SizedBox(height: spacing.md),
                  finesCard,
                  SizedBox(height: spacing.md),
                  historyCard,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Membership and contact details, as label/value pairs.
class _MemberDetailsCard extends StatelessWidget {
  const _MemberDetailsCard({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final member = placeholderMemberById(memberId);
    final notSet = l10n.commonNotSet;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionCard(
          title: l10n.memberDetailMembership,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, row) in <(String, String)>[
                (l10n.fieldCardNumber, member.cardNumber),
                (l10n.fieldCategory, member.category.label(l10n)),
                (l10n.commonStatus, member.status.label(l10n)),
                (l10n.fieldJoined, member.joined),
                (l10n.fieldExpires, member.expires),
                (l10n.fieldDateOfBirth, member.dateOfBirth ?? notSet),
                (l10n.fieldGuardian, member.guardian ?? notSet),
              ].indexed) ...[
                if (index > 0) SizedBox(height: spacing.sm),
                AppDetailRow(label: row.$1, child: Text(row.$2)),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        SectionCard(
          title: l10n.memberDetailContact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, row) in <(String, String)>[
                (l10n.fieldEmail, member.email ?? notSet),
                (l10n.fieldPhone, member.phone ?? notSet),
                (l10n.fieldAddress, member.address ?? notSet),
              ].indexed) ...[
                if (index > 0) SizedBox(height: spacing.sm),
                AppDetailRow(label: row.$1, child: Text(row.$2)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
