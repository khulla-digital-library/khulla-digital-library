import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/components/navigation_tile.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The catalogue's landing page: the size of the collection, the three lists
/// behind it, and what was accessioned most recently.
///
/// It owns no resource of its own — titles, copies and authors each have
/// their own sub-feature — so this page is a board, not a list, and takes the
/// wide content cap like the dashboard does.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final titles = placeholderTitles;
    const copies = placeholderCopies;
    final available = copies
        .where((copy) => copy.status == CopyStatus.available)
        .length;

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
                CollectionHeader(
                  title: l10n.catalogHeading,
                  subtitle: l10n.catalogSubtitle,
                  actionLabel: l10n.titlesAdd,
                  onAction: () => context.go(Routes.catalogTitleNew),
                ),
                SizedBox(height: spacing.lg),
                AppResponsiveGrid(
                  children: [
                    AppStatTile(
                      label: l10n.catalogStatTitles,
                      value: '${titles.length}',
                      icon: Icons.menu_book_rounded,
                      onTap: () => context.go(Routes.catalogTitles),
                    ),
                    AppStatTile(
                      label: l10n.catalogStatCopies,
                      value: '${copies.length}',
                      icon: Icons.inventory_2_rounded,
                      tone: AppStatusTone.brand,
                      onTap: () => context.go(Routes.catalogCopies),
                    ),
                    AppStatTile(
                      label: l10n.catalogStatAvailable,
                      value: '$available',
                      icon: Icons.check_circle_outline_rounded,
                      tone: AppStatusTone.success,
                      onTap: () => context.go(Routes.catalogCopies),
                    ),
                    AppStatTile(
                      label: l10n.catalogStatAuthors,
                      value: '${placeholderAuthors.length}',
                      icon: Icons.person_outline_rounded,
                      tone: AppStatusTone.info,
                      onTap: () => context.go(Routes.catalogAuthors),
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                AppResponsiveGrid(
                  mediumColumns: 3,
                  largeColumns: 3,
                  children: [
                    NavigationTile(
                      label: l10n.titlesHeading,
                      description: l10n.catalogBrowseTitlesBody,
                      count: '${titles.length}',
                      icon: Icons.menu_book_rounded,
                      route: Routes.catalogTitles,
                    ),
                    NavigationTile(
                      label: l10n.copiesHeading,
                      description: l10n.catalogBrowseCopiesBody,
                      count: '${copies.length}',
                      icon: Icons.inventory_2_rounded,
                      route: Routes.catalogCopies,
                    ),
                    NavigationTile(
                      label: l10n.authorsHeading,
                      description: l10n.catalogBrowseAuthorsBody,
                      count: '${placeholderAuthors.length}',
                      icon: Icons.people_outline_rounded,
                      route: Routes.catalogAuthors,
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                _RecentlyCatalogued(titles: titles.take(5).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The last handful of accessions, as a bounded table inside a card.
///
/// [AppTable] rather than [AppSliverTable] on purpose: five known rows, built
/// once, with no query behind them to grow the list.
class _RecentlyCatalogued extends StatelessWidget {
  const _RecentlyCatalogued({required this.titles});

  final List<CatalogTitle> titles;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.catalogRecentTitle,
      subtitle: l10n.catalogRecentSubtitle,
      icon: Icons.history_rounded,
      trailing: AppTextButton(
        onPressed: () => context.go(Routes.catalogTitles),
        child: Text(l10n.commonOpen),
      ),
      child: titles.isEmpty
          ? AppEmptyView(
              icon: Icons.menu_book_rounded,
              title: l10n.catalogRecentEmptyTitle,
              message: l10n.catalogRecentEmptyBody,
            )
          : AppTable<CatalogTitle>(
              items: titles,
              onRowTap: (title) => context.go(Routes.catalogTitle(title.id)),
              columns: [
                AppTableColumn<CatalogTitle>(
                  id: 'title',
                  label: l10n.titlesColumnTitle,
                  flex: 3,
                  cellBuilder: (context, title) => Text(title.title),
                ),
                AppTableColumn<CatalogTitle>(
                  id: 'author',
                  label: l10n.titlesColumnAuthor,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, title) => Text(
                    title.author,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<CatalogTitle>(
                  id: 'shelf',
                  label: l10n.titlesColumnShelf,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, title) => Text(title.shelf),
                ),
                AppTableColumn<CatalogTitle>(
                  id: 'addedOn',
                  label: l10n.fieldAddedOn,
                  alignment: Alignment.centerRight,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, title) => Text(
                    title.addedOn,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
