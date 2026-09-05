import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/circulation/presentation/cubit/loan_list_cubit.dart';
import 'package:khulla/features/circulation/circulation/presentation/cubit/loan_list_state.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/navigation_group.dart';
import 'package:khulla/shared/components/navigation_tile.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The desk: what is out, what is due back, and what is late.
///
/// One page rather than a landing screen plus a list, because the loans table
/// *is* what a librarian came here to look at. [LoanListCubit] supplies the
/// counts, the open-loan query and the holds figure for the stat strip — tapping
/// *Overdue* selects the same rows the chip does. Renew and mark lost in the row
/// menu still toast as not wired; return routes to the returns desk.
class CirculationPage extends StatelessWidget {
  const CirculationPage({super.key});

  bool _isFiltered(LoanListState state) =>
      state.query.search.isNotEmpty || state.query.status != null;

  List<AppTableColumn<Loan>> _columns(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<Loan>(
        id: 'title',
        label: l10n.loansColumnTitle,
        flex: 4,
        sortable: true,
        cellBuilder: (context, loan) =>
            Text(loan.titleName ?? l10n.commonNotSet),
      ),
      AppTableColumn<Loan>(
        id: 'member',
        label: l10n.loansColumnMember,
        flex: 3,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, loan) =>
            Text(loan.memberName ?? l10n.commonNotSet),
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
        sortable: true,
        showFrom: FormFactor.large,
        cellBuilder: (context, loan) => Text(loan.issuedOn, style: muted),
      ),
      AppTableColumn<Loan>(
        id: 'due',
        label: l10n.loansColumnDue,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, loan) => Text(loan.dueOn),
      ),
      AppTableColumn<Loan>(
        id: 'fine',
        label: l10n.loansColumnFine,
        width: 100,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, loan) => Text(
          loan.accruedFine.isZero
              ? l10n.commonNotSet
              : loan.accruedFine.display(),
          style: loan.accruedFine.isZero
              ? muted
              : context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
      AppTableColumn<Loan>(
        id: 'status',
        label: l10n.commonStatus,
        width: 120,
        cellBuilder: (context, loan) => AppStatusBadge(
          dense: true,
          label: loan.status.label(l10n),
          tone: loan.status.tone,
        ),
      ),
      AppTableColumn<Loan>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, loan) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.loansReturn,
              icon: AppIcons.checkIn,
              onSelected: () => context.go(Routes.circulationReturn),
            ),
            AppMenuAction(
              label: l10n.loansRenew,
              icon: AppIcons.refresh,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.loansViewMember,
              icon: AppIcons.person,
              onSelected: () => context.go(Routes.member(loan.memberId)),
            ),
            AppMenuAction(
              label: l10n.loansMarkLost,
              icon: AppIcons.help,
              isDestructive: true,
              onSelected: () => showNotWiredToast(context),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final cubit = context.read<LoanListCubit>();

    return BlocBuilder<LoanListCubit, LoanListState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadOpenLoans,
          );
        }

        final isFiltered = _isFiltered(state);
        final sort = AppTableSort(
          columnId: _displaySortColumn(state.query.sortColumn),
          ascending: state.query.sortAscending,
        );

        return CollectionPageView<Loan>(
          intro: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppStatStrip(
                tiles: [
                  AppStatTile(
                    label: l10n.circulationStatOnLoan,
                    value: '${state.onLoanCount}',
                    icon: AppIcons.transfer,
                    tone: AppStatusTone.brand,
                    onTap: () => cubit.statusFilterChanged(null),
                  ),
                  AppStatTile(
                    label: l10n.circulationStatDueToday,
                    value: '${state.dueTodayCount}',
                    icon: AppIcons.event,
                    tone: AppStatusTone.warning,
                    onTap: () => cubit.statusFilterChanged(LoanStatus.dueToday),
                  ),
                  AppStatTile(
                    label: l10n.circulationStatOverdue,
                    value: '${state.overdueCount}',
                    icon: AppIcons.error,
                    tone: AppStatusTone.danger,
                    onTap: () => cubit.statusFilterChanged(LoanStatus.overdue),
                  ),
                  AppStatTile(
                    label: l10n.circulationStatHolds,
                    value: '${state.holdsCount}',
                    icon: AppIcons.bookmark,
                    tone: AppStatusTone.info,
                    onTap: () => context.go(Routes.circulationReservations),
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              AppSectionHeader(
                title: l10n.circulationDeskTitle,
                subtitle: l10n.circulationDeskSubtitle,
              ),
              SizedBox(height: spacing.md),
              NavigationGroup(
                children: [
                  NavigationTile(
                    label: l10n.circulationCheckOut,
                    description: l10n.checkOutSubtitle,
                    icon: AppIcons.scan,
                    route: Routes.circulationCheckOut,
                  ),
                  NavigationTile(
                    label: l10n.circulationReturn,
                    description: l10n.returnsSubtitle,
                    icon: AppIcons.checkIn,
                    route: Routes.circulationReturn,
                  ),
                  NavigationTile(
                    label: l10n.circulationReservations,
                    description: l10n.reservationsSubtitle,
                    count: '${state.holdsCount}',
                    icon: AppIcons.bookmark,
                    route: Routes.circulationReservations,
                  ),
                  NavigationTile(
                    label: l10n.circulationFines,
                    description: l10n.finesSubtitle,
                    icon: AppIcons.wallet,
                    route: Routes.circulationFines,
                  ),
                ],
              ),
              SizedBox(height: spacing.lg),
              AppSectionHeader(
                title: l10n.circulationLoansTitle,
                subtitle: l10n.circulationLoansSubtitle,
              ),
            ],
          ),
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.circulationSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: cubit.searchChanged,
            ),
            filters: [
              AppFilterChip(
                label: l10n.circulationFilterOnLoan,
                icon: AppIcons.transfer,
                selected: state.query.status == LoanStatus.onLoan,
                onSelected: (selected) => cubit.statusFilterChanged(
                  selected ? LoanStatus.onLoan : null,
                ),
              ),
              AppFilterChip(
                label: l10n.circulationFilterDueToday,
                icon: AppIcons.event,
                tone: AppStatusTone.warning,
                selected: state.query.status == LoanStatus.dueToday,
                onSelected: (selected) => cubit.statusFilterChanged(
                  selected ? LoanStatus.dueToday : null,
                ),
              ),
              AppFilterChip(
                label: l10n.circulationFilterOverdue,
                icon: AppIcons.error,
                tone: AppStatusTone.danger,
                selected: state.query.status == LoanStatus.overdue,
                onSelected: (selected) => cubit.statusFilterChanged(
                  selected ? LoanStatus.overdue : null,
                ),
              ),
            ],
            actions: [
              if (isFiltered)
                AppTextButton(
                  onPressed: cubit.clearFilters,
                  child: Text(l10n.commonClearFilters),
                ),
              AppButton(
                size: AppButtonSize.medium,
                variant: AppButtonVariant.outline,
                onPressed: () => context.go(Routes.circulationReturn),
                child: Text(l10n.circulationReturn),
              ),
            ],
          ),
          items: state.loans,
          columns: _columns(context, l10n),
          sort: sort,
          onSort: (next) => cubit.sortChanged(next.columnId, next.ascending),
          onRowTap: (loan) => context.go(Routes.member(loan.memberId)),
          compactBuilder: (context, loan) => _LoanCard(loan: loan),
          emptyState: isFiltered
              ? AppEmptyView(
                  icon: AppIcons.noResults,
                  title: l10n.commonNoMatchesTitle,
                  message: l10n.commonNoMatchesBody,
                  actionLabel: l10n.commonClearFilters,
                  onAction: cubit.clearFilters,
                )
              : AppEmptyView(
                  icon: AppIcons.transfer,
                  title: l10n.circulationLoansEmptyTitle,
                  message: l10n.circulationLoansEmptyBody,
                  actionLabel: l10n.circulationCheckOut,
                  onAction: () => context.go(Routes.circulationCheckOut),
                ),
        );
      },
    );
  }

  String _displaySortColumn(String columnId) => switch (columnId) {
    'memberName' => 'member',
    'titleName' => 'title',
    'checkedOutAt' => 'issued',
    'barcode' => 'barcode',
    _ => 'due',
  };
}

class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});

  final Loan loan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: () => context.go(Routes.member(loan.memberId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.titleName ?? l10n.commonNotSet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                AppStatusBadge(
                  dense: true,
                  label: loan.status.label(l10n),
                  tone: loan.status.tone,
                ),
              ],
            ),
            SizedBox(height: spacing.xxs),
            Text(
              loan.memberName ?? l10n.commonNotSet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              loan.accruedFine.isZero
                  ? '${l10n.loansColumnDue} ${loan.dueOn}'
                  : '${l10n.loansColumnDue} ${loan.dueOn} · ${loan.accruedFine.display()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: loan.accruedFine.isZero
                    ? scheme.onSurfaceVariant
                    : scheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
