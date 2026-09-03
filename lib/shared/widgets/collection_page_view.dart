import 'package:khulla_ui/khulla_ui.dart';

/// The page recipe every collection screen in the app follows.
///
/// Four bands, stacked 12px apart: the **heading row** with the page's one
/// action, the **filter row**, the **table** in its own bordered wrapper, and
/// the **pagination row**.
///
/// Only the table is boxed. Wrapping the heading and the filters inside the
/// same border as the rows makes the whole screen read as one heavy object
/// and costs 32px of vertical room on a screen whose job is to show as many
/// rows as it can; leaving them outside lets the border say exactly one
/// thing — *here is the data* — which is what makes the table the subject of
/// the page.
///
/// The wrapper is a [DecoratedSliver] rather than an [AppCard] around a list,
/// so the table inside it stays lazy. A catalogue of ten thousand titles must
/// not lay out ten thousand rows to draw a border.
class CollectionPageView<T> extends StatelessWidget {
  const CollectionPageView({
    required this.header,
    required this.items,
    required this.columns,
    required this.emptyState,
    this.toolbar,
    this.intro,
    this.onRowTap,
    this.isSelected,
    this.sort,
    this.onSort,
    this.compactBuilder,
    this.compactExtent = 116,
    this.footer,
    super.key,
  });

  /// The card's heading row: what this collection is, and its one action.
  final Widget header;

  /// Search, filters and view controls, under the heading.
  final Widget? toolbar;

  /// Anything above the card — a row of stat tiles, a banner.
  final Widget? intro;

  /// The page of records to draw. Paging happens before this.
  final List<T> items;

  /// The columns, in display order.
  final List<AppTableColumn<T>> columns;

  /// Rendered in place of the table when [items] is empty. Pass the *right*
  /// empty state: "nothing catalogued yet" and "nothing matched" are
  /// different screens.
  final Widget emptyState;

  /// Opens a record.
  final void Function(T item)? onRowTap;

  /// Marks a row as the picked one.
  final bool Function(T item)? isSelected;

  /// The active sort, reported to the caller and turned into an `ORDER BY`.
  final AppTableSort? sort;

  /// Called when a column header is picked.
  final ValueChanged<AppTableSort>? onSort;

  /// Renders one record as a card, for windows too narrow for a table.
  final Widget Function(BuildContext context, T item)? compactBuilder;

  /// The fixed height of a compact card row.
  final double compactExtent;

  /// The pagination footer.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final bar = toolbar;
    final end = footer;
    final top = intro;

    final tableWrapper = BoxDecoration(
      borderRadius: BorderRadius.circular(context.appRadius.container),
      border: Border.all(color: colors.hairline),
    );

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.pageVertical,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverMainAxisGroup(
              slivers: [
                if (top != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: spacing.lg),
                      child: top,
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacing.sm),
                    child: header,
                  ),
                ),
                if (bar != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: spacing.sm),
                      child: bar,
                    ),
                  ),
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: DecoratedBox(
                      decoration: tableWrapper,
                      child: emptyState,
                    ),
                  )
                else
                  DecoratedSliver(
                    decoration: tableWrapper,
                    sliver: AppSliverTable<T>(
                      items: items,
                      columns: columns,
                      onRowTap: onRowTap,
                      isSelected: isSelected,
                      sort: sort,
                      onSort: onSort,
                      compactBuilder: compactBuilder,
                      compactExtent: compactExtent,
                      pinHeader: false,
                    ),
                  ),
                if (end != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: spacing.xxs),
                      child: end,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
