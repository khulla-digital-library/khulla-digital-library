import 'package:khulla_ui/khulla_ui.dart';

/// The page recipe every collection screen in the app follows.
///
/// One card holds the whole collection: its heading and primary action, the
/// search and filter toolbar, the table, and the pagination footer. Binding
/// them into a single surface is what makes a list screen read as one object
/// — a header floating above a bare table always looks like two screens that
/// happened to load together.
///
/// The card is a [DecoratedSliver] rather than an [AppCard] wrapped around a
/// list, so the table inside it stays lazy. A catalogue of ten thousand
/// titles must not lay out ten thousand rows to draw a border.
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
    final scheme = context.colorScheme;
    final bar = toolbar;
    final end = footer;
    final top = intro;
    final compact = context.formFactor.isCompact;

    final cardDecoration = BoxDecoration(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(context.appRadius.card),
      border: Border.all(color: colors.hairlineStrong),
      boxShadow: context.appShadows.card,
    );

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          if (top != null)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                spacing.page,
                spacing.lg,
                spacing.page,
                0,
              ),
              sliver: SliverToBoxAdapter(child: top),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: DecoratedSliver(
              decoration: cardDecoration,
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        spacing.md,
                        spacing.md,
                        spacing.md,
                        bar == null ? spacing.sm : spacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          header,
                          if (bar != null) ...[
                            SizedBox(height: spacing.md),
                            bar,
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: spacing.md,
                          vertical: spacing.xlg,
                        ),
                        child: emptyState,
                      ),
                    )
                  else ...[
                    AppSliverTable<T>(
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
                    if (end != null)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: compact ? spacing.xs : 0,
                          ),
                          child: end,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
