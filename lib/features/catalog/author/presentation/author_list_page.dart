import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/author/presentation/widgets/author_card.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_author.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The people and organisations the catalogue credits.
///
/// A short list compared with the titles behind it, so it is unpaginated: the
/// search field is the only narrowing the screen needs until an authority
/// file with thousands of names exists.
class AuthorListPage extends StatefulWidget {
  const AuthorListPage({super.key});

  @override
  State<AuthorListPage> createState() => _AuthorListPageState();
}

class _AuthorListPageState extends State<AuthorListPage> {
  String _query = '';
  AppTableSort _sort = const AppTableSort(columnId: 'name');

  void _clearFilters() => setState(() => _query = '');

  List<CatalogAuthor> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final author in placeholderAuthors)
        if (needle.isEmpty || author.name.toLowerCase().contains(needle))
          author,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'titles' => a.titleCount.compareTo(b.titleCount),
        _ => a.name.compareTo(b.name),
      };
      return _sort.ascending ? order : -order;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;
    final spacing = context.appSpacing;
    final matches = _matches;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return CollectionPageView<CatalogAuthor>(
      summary: l10n.authorsSubtitle('${placeholderAuthors.length}'),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.authorsSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() => _query = value),
        ),
      ),
      items: matches,
      sort: _sort,
      onSort: (next) => setState(() => _sort = next),
      onRowTap: (author) => context.go(Routes.catalogAuthor(author.id)),
      compactBuilder: (context, author) => AuthorCard(
        author: author,
        titlesLabel: l10n.authorsSubtitle('${author.titleCount}'),
        onTap: () => context.go(Routes.catalogAuthor(author.id)),
      ),
      compactExtent: 88,
      columns: [
        AppTableColumn<CatalogAuthor>(
          id: 'name',
          label: l10n.authorsColumnName,
          flex: 4,
          sortable: true,
          cellBuilder: (context, author) => Row(
            children: [
              AppAvatar(initials: author.initials, size: 28),
              SizedBox(width: spacing.xs),
              Flexible(child: Text(author.name)),
            ],
          ),
        ),
        AppTableColumn<CatalogAuthor>(
          id: 'lifespan',
          label: l10n.authorsColumnLifespan,
          flex: 2,
          showFrom: FormFactor.medium,
          cellBuilder: (context, author) =>
              Text(author.lifespan ?? l10n.commonNotSet, style: muted),
        ),
        AppTableColumn<CatalogAuthor>(
          id: 'nationality',
          label: l10n.authorsColumnNationality,
          flex: 2,
          showFrom: FormFactor.expanded,
          cellBuilder: (context, author) =>
              Text(author.nationality ?? l10n.commonNotSet, style: muted),
        ),
        AppTableColumn<CatalogAuthor>(
          id: 'titles',
          label: l10n.authorsColumnTitles,
          width: 90,
          sortable: true,
          alignment: Alignment.centerRight,
          cellBuilder: (context, author) => Text('${author.titleCount}'),
        ),
      ],
      emptyState: _query.isEmpty
          ? AppEmptyView(
              icon: AppIcons.people,
              title: l10n.authorsEmptyTitle,
              message: l10n.authorsEmptyBody,
              actionLabel: l10n.authorsAdd,
              onAction: () => showNotWiredToast(context),
            )
          : AppEmptyView(
              icon: AppIcons.noResults,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            ),
    );
  }
}
