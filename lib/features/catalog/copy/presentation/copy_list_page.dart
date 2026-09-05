import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/copy/presentation/cubit/copy_cubit.dart';
import 'package:khulla/features/catalog/copy/presentation/cubit/copy_state.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_card.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_status_badge.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/presentation/title_form_dialog.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every physical item, across every title.
class CopyListPage extends StatelessWidget {
  const CopyListPage({super.key});

  static const List<CopyStatus> _filterableStatuses = [
    CopyStatus.available,
    CopyStatus.onLoan,
    CopyStatus.reserved,
    CopyStatus.lost,
    CopyStatus.damaged,
  ];

  List<AppTableColumn<Copy>> _columns(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<Copy>(
        id: 'barcode',
        label: l10n.copiesColumnBarcode,
        flex: 2,
        sortable: true,
        cellBuilder: (context, copy) => Text(copy.barcode),
      ),
      AppTableColumn<Copy>(
        id: 'title',
        label: l10n.copiesColumnTitle,
        flex: 4,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, copy) => Text(copy.titleName),
      ),
      AppTableColumn<Copy>(
        id: 'shelf',
        label: l10n.copiesColumnShelf,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, copy) => Text(copy.shelf, style: muted),
      ),
      AppTableColumn<Copy>(
        id: 'condition',
        label: l10n.copiesColumnCondition,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, copy) =>
            Text(copy.condition.label(l10n), style: muted),
      ),
      AppTableColumn<Copy>(
        id: 'borrower',
        label: l10n.copiesColumnBorrower,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, copy) =>
            Text(copy.borrower ?? l10n.commonNotSet, style: muted),
      ),
      AppTableColumn<Copy>(
        id: 'status',
        label: l10n.commonStatus,
        width: 130,
        cellBuilder: (context, copy) => CopyStatusBadge(status: copy.status),
      ),
      AppTableColumn<Copy>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, copy) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.commonOpen,
              icon: AppIcons.openExternal,
              onSelected: () => context.go(Routes.catalogTitle(copy.titleId)),
            ),
            AppMenuAction(
              label: l10n.copiesMarkLost,
              icon: AppIcons.help,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.copiesMarkDamaged,
              icon: AppIcons.damage,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.copiesWithdraw,
              icon: AppIcons.delete,
              isDestructive: true,
              onSelected: () => showNotWiredToast(context),
            ),
          ],
        ),
      ),
    ];
  }

  bool _isFiltered(CopyState state) =>
      state.query.search.isNotEmpty || state.query.statuses.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<CopyCubit>();

    return BlocBuilder<CopyCubit, CopyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadCopies,
          );
        }

        final pageSize = state.query.limit;
        final pageCount = (state.totalCount / pageSize).ceil();
        final page = (state.query.offset / pageSize).floor().clamp(
          0,
          pageCount == 0 ? 0 : pageCount - 1,
        );
        final start = state.totalCount == 0 ? 0 : page * pageSize;
        final end = (start + state.copies.length).clamp(0, state.totalCount);
        final sort = AppTableSort(
          columnId: state.query.sortColumn,
          ascending: state.query.sortAscending,
        );

        return CollectionPageView<Copy>(
          summary: l10n.copiesSubtitle('${state.totalCount}'),
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.copiesSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: cubit.searchChanged,
            ),
            filters: [
              for (final status in _filterableStatuses)
                AppFilterChip(
                  label: status.label(l10n),
                  tone: status.tone,
                  selected: state.query.statuses.contains(status),
                  onSelected: (selected) =>
                      cubit.statusFilterChanged(status, selected),
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
          items: state.copies,
          columns: _columns(context, l10n),
          sort: sort,
          onSort: (next) => cubit.sortChanged(next.columnId, next.ascending),
          onRowTap: (copy) => context.go(Routes.catalogTitle(copy.titleId)),
          compactBuilder: (context, copy) => CopyCard(
            copy: copy,
            onTap: () => context.go(Routes.catalogTitle(copy.titleId)),
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
                  icon: AppIcons.inventory,
                  title: l10n.copiesEmptyTitle,
                  message: l10n.copiesEmptyBody,
                  actionLabel: l10n.copiesAdd,
                  onAction: () => TitleFormDialog.show(context),
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
