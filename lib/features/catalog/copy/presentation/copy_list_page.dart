import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_card.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_status_badge.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_copy.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every physical item, across every title.
///
/// The holdings view: a shelf-reading list, a place to find one barcode, and
/// the screen a librarian uses to write off a copy that never came back. Its
/// filters are copy standings, not title availability — the distinction the
/// whole catalogue rests on.
class CopyListPage extends StatefulWidget {
  const CopyListPage({super.key});

  @override
  State<CopyListPage> createState() => _CopyListPageState();
}

class _CopyListPageState extends State<CopyListPage> {
  static const int _pageSize = 8;
  static const List<CopyStatus> _filterableStatuses = [
    CopyStatus.available,
    CopyStatus.onLoan,
    CopyStatus.overdue,
    CopyStatus.reserved,
    CopyStatus.lost,
    CopyStatus.damaged,
  ];

  String _query = '';
  final Set<CopyStatus> _statuses = {};
  AppTableSort _sort = const AppTableSort(columnId: 'barcode');
  int _page = 0;

  bool get _isFiltered => _query.isNotEmpty || _statuses.isNotEmpty;

  void _clearFilters() => setState(() {
    _query = '';
    _statuses.clear();
    _page = 0;
  });

  List<CatalogCopy> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final copy in placeholderCopies)
        if ((needle.isEmpty ||
                copy.barcode.toLowerCase().contains(needle) ||
                copy.titleName.toLowerCase().contains(needle) ||
                copy.shelf.toLowerCase().contains(needle)) &&
            (_statuses.isEmpty || _statuses.contains(copy.status)))
          copy,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'title' => a.titleName.compareTo(b.titleName),
        'shelf' => a.shelf.compareTo(b.shelf),
        'acquired' => a.acquired.compareTo(b.acquired),
        _ => a.barcode.compareTo(b.barcode),
      };
      return _sort.ascending ? order : -order;
    });
  }

  List<AppTableColumn<CatalogCopy>> _columns(AppLocalizations l10n) {
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<CatalogCopy>(
        id: 'barcode',
        label: l10n.copiesColumnBarcode,
        flex: 2,
        sortable: true,
        cellBuilder: (context, copy) => Text(copy.barcode),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'title',
        label: l10n.copiesColumnTitle,
        flex: 4,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, copy) => Text(copy.titleName),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'shelf',
        label: l10n.copiesColumnShelf,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, copy) => Text(copy.shelf, style: muted),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'condition',
        label: l10n.copiesColumnCondition,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, copy) =>
            Text(copy.condition.label(l10n), style: muted),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'borrower',
        label: l10n.copiesColumnBorrower,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, copy) =>
            Text(copy.borrower ?? l10n.commonNotSet, style: muted),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'status',
        label: l10n.commonStatus,
        width: 130,
        cellBuilder: (context, copy) => CopyStatusBadge(status: copy.status),
      ),
      AppTableColumn<CatalogCopy>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, copy) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.commonOpen,
              icon: Icons.open_in_new_rounded,
              onSelected: () => context.go(Routes.catalogTitle(copy.titleId)),
            ),
            AppMenuAction(
              label: l10n.copiesMarkLost,
              icon: Icons.help_outline_rounded,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.copiesMarkDamaged,
              icon: Icons.report_gmailerrorred_rounded,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.copiesWithdraw,
              icon: Icons.delete_outline_rounded,
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
    final matches = _matches;
    final pageCount = (matches.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount == 0 ? 0 : pageCount - 1);
    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, matches.length);

    return CollectionPageView<CatalogCopy>(
      header: CollectionHeader(
        title: l10n.copiesHeading,
        subtitle: l10n.copiesSubtitle('${placeholderCopies.length}'),
        actionLabel: l10n.copiesAdd,
        onAction: () => showNotWiredToast(context),
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.copiesSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() {
            _query = value;
            _page = 0;
          }),
        ),
        filters: [
          for (final status in _filterableStatuses)
            AppFilterChip(
              label: status.label(l10n),
              tone: status.tone,
              selected: _statuses.contains(status),
              onSelected: (selected) => setState(() {
                if (selected) {
                  _statuses.add(status);
                } else {
                  _statuses.remove(status);
                }
                _page = 0;
              }),
            ),
        ],
        actions: [
          if (_isFiltered)
            AppTextButton(
              onPressed: _clearFilters,
              child: Text(l10n.commonClearFilters),
            ),
        ],
      ),
      items: matches.sublist(start, end),
      columns: _columns(l10n),
      sort: _sort,
      onSort: (next) => setState(() {
        _sort = next;
        _page = 0;
      }),
      onRowTap: (copy) => context.go(Routes.catalogTitle(copy.titleId)),
      compactBuilder: (context, copy) => CopyCard(
        copy: copy,
        onTap: () => context.go(Routes.catalogTitle(copy.titleId)),
      ),
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: Icons.inventory_2_outlined,
              title: l10n.copiesEmptyTitle,
              message: l10n.copiesEmptyBody,
              actionLabel: l10n.copiesAdd,
              onAction: () => showNotWiredToast(context),
            ),
      footer: AppPagination(
        rangeLabel: l10n.commonRangeLabel(
          '${start + 1}',
          '$end',
          '${matches.length}',
        ),
        previousTooltip: l10n.commonPreviousPage,
        nextTooltip: l10n.commonNextPage,
        onPrevious: page == 0 ? null : () => setState(() => _page = page - 1),
        onNext: page >= pageCount - 1
            ? null
            : () => setState(() => _page = page + 1),
      ),
    );
  }
}
