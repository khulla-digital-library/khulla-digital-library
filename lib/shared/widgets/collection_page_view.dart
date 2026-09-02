import 'package:khulla_ui/khulla_ui.dart';

/// The page recipe for a shell tab whose content is a collection.
///
/// Header, toolbar, table and footer in one scroll view, assembled the way
/// DESIGN.md's recipe describes: every section is a sliver, so the page
/// scrolls as one surface and the rows stay lazy however long the collection
/// gets. Screens differ in their columns and their copy, not in this
/// scaffolding, which is why it is written once here.
///
/// The empty state is passed in rather than derived: "nothing catalogued yet"
/// and "nothing matches *dickens*" are different states with different
/// actions, and only the caller knows which one it is in.
class CollectionPageView<T> extends StatelessWidget {
  const CollectionPageView({
    required this.header,
    required this.items,
    required this.columns,
    required this.emptyState,
    this.toolbar,
    this.onRowTap,
    this.isSelected,
    this.sort,
    this.onSort,
    this.compactBuilder,
    this.compactExtent = 108,
    this.footer,
    super.key,
  });

  /// The title block — typically a `CollectionHeader`.
  final Widget header;

  /// Search, filters and secondary actions — typically an [AppToolbar].
  final Widget? toolbar;

  /// The rows on this page of the collection.
  final List<T> items;

  /// The table's columns, in display order.
  final List<AppTableColumn<T>> columns;

  /// What to show when [items] is empty.
  final Widget emptyState;

  /// Opens a record.
  final void Function(T item)? onRowTap;

  /// Whether a record is the one open beside the table.
  final bool Function(T item)? isSelected;

  /// The current ordering, reflected in the pinned header.
  final AppTableSort? sort;

  /// Called when a sortable heading is clicked.
  final ValueChanged<AppTableSort>? onSort;

  /// Renders one record as a card below [FormFactor.medium].
  final Widget Function(BuildContext context, T item)? compactBuilder;

  /// Fixed height of a compact card, so the list keeps its `itemExtent`.
  final double compactExtent;

  /// The strip under the table — typically [AppPagination].
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final bar = toolbar;
    final end = footer;

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.md,
            ),
            sliver: SliverList.list(
              children: [
                header,
                if (bar != null) ...[SizedBox(height: spacing.lg), bar],
              ],
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.page,
                  vertical: spacing.xlg,
                ),
                child: emptyState,
              ),
            )
          else ...[
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing.page),
              sliver: AppSliverTable<T>(
                items: items,
                columns: columns,
                onRowTap: onRowTap,
                isSelected: isSelected,
                sort: sort,
                onSort: onSort,
                compactBuilder: compactBuilder,
                compactExtent: compactExtent,
              ),
            ),
            if (end != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    spacing.page,
                    spacing.sm,
                    spacing.page,
                    spacing.xlg,
                  ),
                  child: end,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
