import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/presentation/cubit/member_detail_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_detail_state.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/features/members/presentation/widgets/member_detail_header.dart';
import 'package:khulla/features/members/presentation/widgets/member_fines_card.dart';
import 'package:khulla/features/members/presentation/widgets/member_loans_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One borrower's record: standing, loans, fines, and contact details.
class MemberDetailPage extends StatelessWidget {
  const MemberDetailPage({required this.memberId, super.key});

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
    try {
      await context.read<MemberDetailCubit>().removeMember(memberId);
      if (!context.mounted) return;
      context.go(Routes.members);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _edit(BuildContext context) async {
    final saved = await MemberFormDialog.show(context, memberId: memberId);
    if (saved == true && context.mounted) {
      unawaited(context.read<MemberDetailCubit>().loadMember(memberId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return BlocBuilder<MemberDetailCubit, MemberDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: () =>
                context.read<MemberDetailCubit>().loadMember(memberId),
          );
        }
        final member = state.member;
        if (member == null) {
          return Center(child: Text(l10n.commonNotSet));
        }

        final twoPane = context.formFactor.isAtLeast(FormFactor.expanded);

        final loansCard = MemberLoansCard(
          title: l10n.memberDetailLoansTitle,
          subtitle: l10n.memberDetailLoansSubtitle,
          loans: state.openLoans,
          emptyTitle: l10n.memberDetailLoansEmptyTitle,
          emptyBody: l10n.memberDetailLoansEmptyBody,
        );
        final historyCard = MemberLoansCard(
          title: l10n.memberDetailHistoryTitle,
          subtitle: l10n.memberDetailHistorySubtitle,
          loans: state.historyLoans,
          emptyTitle: l10n.memberDetailHistoryEmptyTitle,
          emptyBody: l10n.memberDetailHistoryEmptyBody,
          isHistory: true,
        );
        final finesCard = MemberFinesCard(
          fines: state.fines,
          onCollect: (_) => showNotWiredToast(context),
        );
        final detailsCard = _MemberDetailsCard(member: member);

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
                          onSelected: () => unawaited(_edit(context)),
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
                          value: '${member.overdueLoans}',
                          icon: AppIcons.error,
                          tone: member.overdueLoans > 0
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
      },
    );
  }
}

class _MemberDetailsCard extends StatelessWidget {
  const _MemberDetailsCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final notSet = l10n.commonNotSet;
    final dateOfBirth = member.dateOfBirth == null
        ? notSet
        : AppDateFormat.format(member.dateOfBirth!);

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
                (l10n.fieldCategory, member.memberTypeName),
                (l10n.commonStatus, member.status.label(l10n)),
                (l10n.fieldJoined, member.joined),
                (
                  l10n.fieldExpires,
                  member.expires.isEmpty ? notSet : member.expires,
                ),
                (l10n.fieldDateOfBirth, dateOfBirth),
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
