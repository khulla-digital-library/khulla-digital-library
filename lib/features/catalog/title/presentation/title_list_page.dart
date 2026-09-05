import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/features/catalog/title/presentation/cubit/title_cubit.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title_state.dart';
import 'package:khulla/features/catalog/title/presentation/title_form_dialog.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/presentation/cubit/reference_data_cubit.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every work the library holds.
///
/// [TitleCubit] owns search, format and availability filters, sort and paging —
/// the same four knobs the placeholder ran in memory, now one SQLite query.
/// Format chips read [ReferenceDataCubit] because formats are reference data,
/// not part of the title query. The [CollectionPageView] shape is unchanged:
/// row tap opens the detail route, the empty state opens [TitleFormDialog].
class TitleListPage extends StatefulWidget {
  const TitleListPage({super.key});

  @override
  State<TitleListPage> createState() => _TitleListPageState();
}

class _TitleListPageState extends State<TitleListPage> {
  bool _isFiltered(TitleState state) =>
      state.query.search.isNotEmpty ||
      state.query.formatId != null ||
      state.query.availableOnly;

  List<AppTableColumn<catalog.Title>> _columns(AppLocalizations l10n) {
    final scheme = context.colorScheme;

    return [
      AppTableColumn<catalog.Title>(
        id: 'title',
        label: l10n.titlesColumnTitle,
        flex: 4,
        sortable: true,
        cellBuilder: (context, title) => Row(
          children: [
            AppIcon(
              title.formatCode.formatIcon,
              size: context.appSpacing.md,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(width: context.appSpacing.xs),
            Flexible(child: Text(title.title)),
          ],
        ),
      ),
      AppTableColumn<catalog.Title>(
        id: 'author',
        label: l10n.titlesColumnAuthor,
        flex: 3,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, title) => Text(
          title.author,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      AppTableColumn<catalog.Title>(
        id: 'isbn',
        label: l10n.titlesColumnIsbn,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, title) => Text(
          title.isbn ?? '',
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      AppTableColumn<catalog.Title>(
        id: 'shelf',
        label: l10n.titlesColumnShelf,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, title) => Text(title.shelf ?? ''),
      ),
      AppTableColumn<catalog.Title>(
        id: 'year',
        label: l10n.titlesColumnYear,
        width: 80,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.large,
        cellBuilder: (context, title) => Text(title.year),
      ),
      AppTableColumn<catalog.Title>(
        id: 'available',
        label: l10n.titlesColumnAvailable,
        width: 110,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.medium,
        cellBuilder: (context, title) => Text(
          l10n.titlesCopiesOf(
            '${title.availableCount}',
            '${title.copyCount}',
          ),
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      AppTableColumn<catalog.Title>(
        id: 'status',
        label: l10n.commonStatus,
        width: 120,
        cellBuilder: (context, title) => AppStatusBadge(
          dense: true,
          label: title.availableCount > 0
              ? l10n.statusAvailable
              : l10n.statusOnLoan,
          tone: title.availableCount > 0
              ? AppStatusTone.success
              : AppStatusTone.brand,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<TitleCubit>();
    final formats = context.watch<ReferenceDataCubit>().state.formats;

    return BlocBuilder<TitleCubit, TitleState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadTitles,
          );
        }

        final pageSize = state.query.limit;
        final pageCount = (state.totalCount / pageSize).ceil();
        final page = (state.query.offset / pageSize).floor().clamp(
          0,
          pageCount == 0 ? 0 : pageCount - 1,
        );
        final start = state.totalCount == 0 ? 0 : page * pageSize;
        final end = (start + state.titles.length).clamp(0, state.totalCount);
        final sort = AppTableSort(
          columnId: state.query.sortColumn,
          ascending: state.query.sortAscending,
        );

        return CollectionPageView<catalog.Title>(
          summary: l10n.titlesSubtitle('${state.totalCount}'),
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.titlesSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: cubit.searchChanged,
            ),
            filters: [
              AppFilterChip(
                label: l10n.statusAvailable,
                icon: AppIcons.success,
                tone: AppStatusTone.success,
                selected: state.query.availableOnly,
                onSelected: cubit.availableOnlyChanged,
              ),
              for (final format in formats)
                AppFilterChip(
                  label: format.label(l10n),
                  icon: format.icon,
                  selected: state.query.formatId == format.id,
                  onSelected: (selected) => cubit.formatFilterChanged(
                    selected ? format.id : null,
                  ),
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
          items: state.titles,
          columns: _columns(l10n),
          sort: sort,
          onSort: (next) => cubit.sortChanged(next.columnId, next.ascending),
          onRowTap: (title) => context.go(Routes.catalogTitle(title.id)),
          compactBuilder: (context, title) => TitleCard(
            title: title,
            onTap: () => context.go(Routes.catalogTitle(title.id)),
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
                  icon: AppIcons.book,
                  title: l10n.titlesEmptyTitle,
                  message: l10n.titlesEmptyBody,
                  actionLabel: l10n.titlesAdd,
                  onAction: () => TitleFormDialog.show(context),
                ),
          footer: AppPagination(
            rangeLabel: l10n.commonShowingRange(
              state.totalCount == 0 ? '0' : '${start + 1}',
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
