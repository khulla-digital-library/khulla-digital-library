import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/domain/catalog_format.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every work the library holds.
///
/// The screen is interface-only: the search, the filters, the ordering and
/// the paging all run over `placeholderTitles` in memory. When
/// `TitleCubit` lands it owns exactly these four pieces of state and turns
/// them into one query — the sort becomes an `ORDER BY`, the page becomes a
/// `LIMIT`, and nothing above this comment changes.
class TitleListPage extends StatefulWidget {
  const TitleListPage({super.key});

  @override
  State<TitleListPage> createState() => _TitleListPageState();
}

class _TitleListPageState extends State<TitleListPage> {
  static const int _pageSize = 8;

  String _query = '';
  CatalogFormat? _format;
  bool _availableOnly = false;
  AppTableSort _sort = const AppTableSort(columnId: 'title');
  int _page = 0;

  bool get _isFiltered =>
      _query.isNotEmpty || _format != null || _availableOnly;

  void _clearFilters() => setState(() {
    _query = '';
    _format = null;
    _availableOnly = false;
    _page = 0;
  });

  /// The rows the current search, filters and ordering select.
  ///
  /// In memory only because there is no table yet. A catalogue of ten
  /// thousand titles sorts in SQLite, not here.
  List<CatalogTitle> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final title in placeholderTitles)
        if ((needle.isEmpty ||
                title.title.toLowerCase().contains(needle) ||
                title.author.toLowerCase().contains(needle) ||
                title.isbn.toLowerCase().contains(needle)) &&
            (_format == null || title.format == _format) &&
            (!_availableOnly || title.available > 0))
          title,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'author' => a.author.compareTo(b.author),
        'year' => a.year.compareTo(b.year),
        'shelf' => a.shelf.compareTo(b.shelf),
        'copies' => a.copies.compareTo(b.copies),
        'available' => a.available.compareTo(b.available),
        _ => a.title.compareTo(b.title),
      };
      return _sort.ascending ? order : -order;
    });
  }

  List<AppTableColumn<CatalogTitle>> _columns(AppLocalizations l10n) {
    final scheme = context.colorScheme;

    return [
      AppTableColumn<CatalogTitle>(
        id: 'title',
        label: l10n.titlesColumnTitle,
        flex: 4,
        sortable: true,
        cellBuilder: (context, title) => Row(
          children: [
            Icon(
              title.format.icon,
              size: context.appSpacing.md,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(width: context.appSpacing.xs),
            Flexible(child: Text(title.title)),
          ],
        ),
      ),
      AppTableColumn<CatalogTitle>(
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
      AppTableColumn<CatalogTitle>(
        id: 'isbn',
        label: l10n.titlesColumnIsbn,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, title) => Text(
          title.isbn,
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      AppTableColumn<CatalogTitle>(
        id: 'shelf',
        label: l10n.titlesColumnShelf,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, title) => Text(title.shelf),
      ),
      AppTableColumn<CatalogTitle>(
        id: 'year',
        label: l10n.titlesColumnYear,
        width: 80,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.large,
        cellBuilder: (context, title) => Text(title.year),
      ),
      AppTableColumn<CatalogTitle>(
        id: 'available',
        label: l10n.titlesColumnAvailable,
        width: 110,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.medium,
        cellBuilder: (context, title) => Text(
          l10n.titlesCopiesOf('${title.available}', '${title.copies}'),
          style: context.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
      AppTableColumn<CatalogTitle>(
        id: 'status',
        label: l10n.commonStatus,
        width: 120,
        cellBuilder: (context, title) => AppStatusBadge(
          dense: true,
          label: title.available > 0 ? l10n.statusAvailable : l10n.statusOnLoan,
          tone: title.available > 0
              ? AppStatusTone.success
              : AppStatusTone.brand,
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
    final rows = matches.sublist(start, end);

    return CollectionPageView<CatalogTitle>(
      header: CollectionHeader(
        title: l10n.titlesHeading,
        subtitle: l10n.titlesSubtitle('${placeholderTitles.length}'),
        actionLabel: l10n.titlesAdd,
        onAction: () => context.go(Routes.catalogTitleNew),
        menuTooltip: l10n.commonMoreActions,
        menuActions: [
          AppMenuAction(
            label: l10n.titlesImport,
            icon: Icons.file_upload_outlined,
            onSelected: () => showNotWiredToast(context),
          ),
          AppMenuAction(
            label: l10n.titlesExport,
            icon: Icons.file_download_outlined,
            onSelected: () => showNotWiredToast(context),
          ),
          AppMenuAction(
            label: l10n.titlesPrintLabels,
            icon: Icons.print_outlined,
            onSelected: () => showNotWiredToast(context),
          ),
        ],
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.titlesSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() {
            _query = value;
            _page = 0;
          }),
        ),
        filters: [
          AppFilterChip(
            label: l10n.statusAvailable,
            icon: Icons.check_circle_outline_rounded,
            tone: AppStatusTone.success,
            selected: _availableOnly,
            onSelected: (selected) => setState(() {
              _availableOnly = selected;
              _page = 0;
            }),
          ),
          for (final format in CatalogFormat.values)
            AppFilterChip(
              label: format.label(l10n),
              icon: format.icon,
              selected: _format == format,
              onSelected: (selected) => setState(() {
                _format = selected ? format : null;
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
      items: rows,
      columns: _columns(l10n),
      sort: _sort,
      onSort: (next) => setState(() {
        _sort = next;
        _page = 0;
      }),
      onRowTap: (title) => context.go(Routes.catalogTitle(title.id)),
      compactBuilder: (context, title) => TitleCard(
        title: title,
        onTap: () => context.go(Routes.catalogTitle(title.id)),
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
              icon: Icons.menu_book_rounded,
              title: l10n.titlesEmptyTitle,
              message: l10n.titlesEmptyBody,
              actionLabel: l10n.titlesAdd,
              onAction: () => context.go(Routes.catalogTitleNew),
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
