import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/presentation/cubit/member_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_state.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/features/members/presentation/widgets/member_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The register: every borrower and how they stand.
class MemberListPage extends StatelessWidget {
  const MemberListPage({super.key});

  List<AppTableColumn<Member>> _columns(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<Member>(
        id: 'name',
        label: l10n.membersColumnName,
        flex: 4,
        sortable: true,
        cellBuilder: (context, member) => Row(
          children: [
            AppAvatar(initials: member.initials, size: 28),
            SizedBox(width: spacing.xs),
            Flexible(child: Text(member.name)),
          ],
        ),
      ),
      AppTableColumn<Member>(
        id: 'card',
        label: l10n.membersColumnCard,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, member) => Text(member.cardNumber, style: muted),
      ),
      AppTableColumn<Member>(
        id: 'category',
        label: l10n.membersColumnCategory,
        flex: 2,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, member) => Row(
          children: [
            AppIcon(
              member.memberTypeCode.memberTypeIcon,
              size: spacing.md,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(width: spacing.xs),
            Flexible(child: Text(member.memberTypeName)),
          ],
        ),
      ),
      AppTableColumn<Member>(
        id: 'loans',
        label: l10n.membersColumnLoans,
        width: 90,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.medium,
        cellBuilder: (context, member) => Text(
          '${member.loansOut}',
          style: member.overdueLoans > 0
              ? context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                )
              : null,
        ),
      ),
      AppTableColumn<Member>(
        id: 'fines',
        label: l10n.membersColumnFines,
        width: 110,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, member) => Text(
          member.finesOwed.isZero
              ? l10n.commonNotSet
              : member.finesOwed.display(),
          style: member.finesOwed.isZero
              ? muted
              : context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
      AppTableColumn<Member>(
        id: 'expires',
        label: l10n.membersColumnExpires,
        flex: 2,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.large,
        cellBuilder: (context, member) => Text(
          member.expires.isEmpty ? l10n.commonNotSet : member.expires,
          style: muted,
        ),
      ),
      AppTableColumn<Member>(
        id: 'status',
        label: l10n.commonStatus,
        width: 130,
        cellBuilder: (context, member) => AppStatusBadge(
          dense: true,
          label: member.status.label(l10n),
          tone: member.status.tone,
        ),
      ),
      AppTableColumn<Member>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, member) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.memberDetailCheckOut,
              icon: AppIcons.scan,
              onSelected: () => context.go(Routes.circulationCheckOut),
            ),
            AppMenuAction(
              label: l10n.memberDetailEdit,
              icon: AppIcons.edit,
              onSelected: () =>
                  MemberFormDialog.show(context, memberId: member.id),
            ),
            AppMenuAction(
              label: l10n.memberDetailRenewMembership,
              icon: AppIcons.renew,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.memberDetailSuspend,
              icon: AppIcons.blocked,
              isDestructive: true,
              onSelected: () => showNotWiredToast(context),
            ),
          ],
        ),
      ),
    ];
  }

  bool _isFiltered(MemberState state) =>
      state.query.search.isNotEmpty ||
      state.query.withLoans ||
      state.query.owesFines ||
      state.query.suspended ||
      state.query.expiring;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MemberCubit>();

    return BlocBuilder<MemberCubit, MemberState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadMembers,
          );
        }

        final pageSize = state.query.limit;
        final pageCount = (state.totalCount / pageSize).ceil();
        final page = (state.query.offset / pageSize).floor().clamp(
          0,
          pageCount == 0 ? 0 : pageCount - 1,
        );
        final start = state.totalCount == 0 ? 0 : page * pageSize;
        final end = (start + state.members.length).clamp(0, state.totalCount);
        final sort = AppTableSort(
          columnId: state.query.sortColumn,
          ascending: state.query.sortAscending,
        );

        return CollectionPageView<Member>(
          summary: l10n.membersSubtitle('${state.totalCount}'),
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.membersSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: cubit.searchChanged,
            ),
            filters: [
              AppFilterChip(
                label: l10n.membersFilterWithLoans,
                icon: AppIcons.transfer,
                selected: state.query.withLoans,
                onSelected: cubit.withLoansChanged,
              ),
              AppFilterChip(
                label: l10n.membersFilterOwesFines,
                icon: AppIcons.wallet,
                tone: AppStatusTone.danger,
                selected: state.query.owesFines,
                onSelected: cubit.owesFinesChanged,
              ),
              AppFilterChip(
                label: l10n.membersFilterExpiring,
                icon: AppIcons.clock,
                tone: AppStatusTone.warning,
                selected: state.query.expiring,
                onSelected: cubit.expiringChanged,
              ),
              AppFilterChip(
                label: l10n.membersFilterSuspended,
                icon: AppIcons.blocked,
                tone: AppStatusTone.danger,
                selected: state.query.suspended,
                onSelected: cubit.suspendedChanged,
              ),
            ],
            actions: [
              if (_isFiltered(state))
                AppTextButton(
                  onPressed: cubit.clearFilters,
                  child: Text(l10n.commonClearFilters),
                ),
            ],
          ),
          items: state.members,
          columns: _columns(context, l10n),
          sort: sort,
          onSort: (next) => cubit.sortChanged(next.columnId, next.ascending),
          onRowTap: (member) => context.go(Routes.member(member.id)),
          compactBuilder: (context, member) => MemberCard(
            member: member,
            onTap: () => context.go(Routes.member(member.id)),
          ),
          emptyState: _isFiltered(state)
              ? AppEmptyView(
                  icon: AppIcons.noResults,
                  title: l10n.commonNoMatchesTitle,
                  message: l10n.commonNoMatchesBody,
                  actionLabel: l10n.commonClearFilters,
                  onAction: cubit.clearFilters,
                )
              : AppEmptyView(
                  icon: AppIcons.people,
                  title: l10n.membersEmptyTitle,
                  message: l10n.membersEmptyBody,
                  actionLabel: l10n.membersAdd,
                  onAction: () => MemberFormDialog.show(context),
                ),
          footer: AppPagination(
            rangeLabel: l10n.commonShowingRange(
              '${start + 1}',
              '$end',
              '${state.totalCount}',
            ),
            previousTooltip: l10n.commonPreviousPage,
            nextTooltip: l10n.commonNextPage,
            pageCount: pageCount,
            currentPage: page,
            onPageSelected: cubit.pageChanged,
            onPrevious: page == 0 ? null : () => cubit.pageChanged(page - 1),
            onNext: page >= pageCount - 1
                ? null
                : () => cubit.pageChanged(page + 1),
          ),
        );
      },
    );
  }
}
