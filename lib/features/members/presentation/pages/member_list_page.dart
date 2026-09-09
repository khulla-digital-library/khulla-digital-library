import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/app/router/app_router.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';
import 'package:khulla/features/members/presentation/cubit/member_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_state.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/member_list_refresh.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/features/members/presentation/widgets/member_card.dart';
import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/utils/permission_context.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The register: every borrower and how they stand.
///
/// The filters are the questions a desk actually asks of it — who is holding
/// something, who owes something, whose card has stopped working — rather
/// than one chip per enum value. [MemberCubit] turns search, those filters,
/// sort and paging into one query. Check-out jumps to the circulation desk.
class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> with DisposeBag {
  late final TextEditingController _search = textController();
  late final GoRouterDelegate _routerDelegate =
      getIt<AppRouter>().router.routerDelegate;

  @override
  void initState() {
    super.initState();
    getIt<MemberListRefresh>().reload = _reload;
    _routerDelegate.addListener(_handleRouteChange);
  }

  @override
  void dispose() {
    _routerDelegate.removeListener(_handleRouteChange);
    getIt<MemberListRefresh>().reload = null;
    super.dispose();
  }

  /// Resets the list whenever the operator leaves the members section —
  /// switching rail tabs, checking out to a member, anything that moves the
  /// location out from under `/members`. The shell keeps every branch alive,
  /// so without this the stale search is still sitting there on return.
  /// Dialogs never change the location, so add/edit dialogs are unaffected.
  void _handleRouteChange() {
    if (!mounted) return;
    final location = _routerDelegate.currentConfiguration.uri.toString();
    if (Routes.isUnder(location, Routes.members)) return;
    final cubit = context.read<MemberCubit>();
    if (cubit.state.query == MemberQuery(limit: cubit.state.query.limit)) {
      return;
    }
    _search.clear();
    cubit.clearFilters();
  }

  void _reload() {
    if (!mounted) return;
    unawaited(context.read<MemberCubit>().loadMembers());
  }

  /// Opens a member's detail page from a clean list: the list cubit outlives
  /// the push (detail is a sub-route), so the search field and its query are
  /// cleared up front — otherwise coming back shows the stale search.
  void _openMember(Member member) {
    _search.clear();
    context.read<MemberCubit>().clearFilters();
    context.go(Routes.member(member.id));
  }

  Future<void> _addMember() async {
    final saved = await MemberFormDialog.show(context);
    if (saved == true && mounted) {
      await context.read<MemberCubit>().loadMembers();
    }
  }

  Future<void> _editMember(Member member) async {
    final saved = await MemberFormDialog.show(context, memberId: member.id);
    if (saved == true && mounted) {
      await context.read<MemberCubit>().loadMembers();
    }
  }

  Future<void> _renewMembership(BuildContext context, Member member) async {
    final l10n = context.l10n;
    try {
      await context.read<MemberCubit>().renewMembership(member.id);
      if (!context.mounted) return;
      AppToast.success(context, message: l10n.memberDetailRenewSuccess);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _suspendMembership(BuildContext context, Member member) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.memberDetailSuspend,
      message: l10n.memberDetailSuspendBody,
      confirmLabel: l10n.memberDetailSuspend,
      cancelLabel: l10n.commonCancel,
    );
    if (!context.mounted || !confirmed) return;
    try {
      await context.read<MemberCubit>().suspendMember(member.id);
      if (!context.mounted) return;
      AppToast.success(context, message: l10n.memberDetailSuspendSuccess);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _unsuspendMembership(BuildContext context, Member member) async {
    final l10n = context.l10n;
    try {
      await context.read<MemberCubit>().unsuspendMember(member.id);
      if (!context.mounted) return;
      AppToast.success(context, message: l10n.memberDetailUnsuspendSuccess);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _archiveMember(BuildContext context, Member member) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.memberDetailArchiveTitle,
      message: l10n.memberDetailArchiveBody,
      confirmLabel: l10n.memberDetailArchive,
      cancelLabel: l10n.commonCancel,
    );
    if (!context.mounted || !confirmed) return;
    try {
      await context.read<MemberCubit>().archiveMember(member.id);
      if (!context.mounted) return;
      AppToast.success(context, message: l10n.memberDetailArchiveSuccess);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  List<AppTableColumn<Member>> _columns(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final canManage = context.canManage(StaffPermission.members);
    final canWorkTheDesk = context.canManage(StaffPermission.circulation);

    return [
      AppTableColumn<Member>(
        id: 'name',
        label: l10n.membersColumnName,
        flex: 3,
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
        sortable: true,
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
        flex: 2,
        sortable: true,
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
        sortable: true,
        showFrom: FormFactor.large,
        cellBuilder: (context, member) => Text(
          member.expires.isEmpty ? l10n.commonNotSet : member.expires,
          style: muted,
        ),
      ),
      AppTableColumn<Member>(
        id: 'status',
        label: l10n.commonStatus,
        flex: 2,
        cellBuilder: (context, member) => AppStatusBadge(
          dense: true,
          label: member.status.label(l10n),
          tone: member.status.tone,
        ),
      ),
      // Two permissions meet in this menu. Editing, renewing, suspending and
      // archiving a member are members work; sending the row to the checkout
      // desk is circulation work, and a role can hold either without the
      // other. With neither, the column itself is gone.
      if (canManage || canWorkTheDesk)
        AppTableColumn<Member>(
          id: 'actions',
          label: l10n.commonActions,
          alignment: Alignment.centerRight,
          cellBuilder: (context, member) => AppMenuButton(
            tooltip: l10n.commonMoreActions,
            actions: [
              if (canWorkTheDesk)
                AppMenuAction(
                  label: l10n.memberDetailCheckOut,
                  icon: AppIcons.scan,
                  onSelected: () => context.go(
                    Routes.circulationCheckOutForMember(member.cardNumber),
                  ),
                ),
              if (canManage) ...[
                AppMenuAction(
                  label: l10n.memberDetailEdit,
                  icon: AppIcons.edit,
                  onSelected: () => unawaited(_editMember(member)),
                ),
                AppMenuAction(
                  label: l10n.memberDetailRenewMembership,
                  icon: AppIcons.renew,
                  onSelected: () =>
                      unawaited(_renewMembership(context, member)),
                ),
                if (member.suspendedAt != null)
                  AppMenuAction(
                    label: l10n.memberDetailUnsuspend,
                    icon: AppIcons.restore,
                    onSelected: () =>
                        unawaited(_unsuspendMembership(context, member)),
                  )
                else
                  AppMenuAction(
                    label: l10n.memberDetailSuspend,
                    icon: AppIcons.blocked,
                    isDestructive: true,
                    onSelected: () =>
                        unawaited(_suspendMembership(context, member)),
                  ),
                AppMenuAction(
                  label: l10n.memberDetailArchive,
                  icon: AppIcons.delete,
                  isDestructive: true,
                  onSelected: () => unawaited(_archiveMember(context, member)),
                ),
              ],
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
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadMembers,
          );
        }

        final bootstrapping = state.isLoading && state.members.isEmpty;

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
          onPageSizeChanged: cubit.limitChanged,
          summary: l10n.membersSubtitle('${state.totalCount}'),
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.membersSearchHint,
              clearTooltip: l10n.commonClearSearch,
              controller: _search,
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
          onRowTap: _openMember,
          compactBuilder: (context, member) => MemberCard(
            member: member,
            onTap: () => _openMember(member),
          ),
          emptyState: bootstrapping
              ? const Center(child: AppSpinner())
              : _isFiltered(state)
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
                  actionLabel: context.canManage(StaffPermission.members)
                      ? l10n.membersAdd
                      : null,
                  onAction: context.canManage(StaffPermission.members)
                      ? () => unawaited(_addMember())
                      : null,
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
