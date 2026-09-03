import 'package:khulla_ui/khulla_ui.dart';

/// The page recipe every collection screen in the app follows.
///
/// Three bands: the **filter row**, the **table** in its own bordered
/// wrapper, and the **pagination row**. The page's name and its one action
/// are in the shell's top bar, so nothing repeats them here.
///
/// The table **fills the window down to the last pixel** rather than sizing
/// to its rows. A bordered box that stops two thirds of the way down the
/// screen reads as a card that ran out of content, and it wastes the room a
/// desk machine has most of: vertical. Filling means the wrapper is an
/// [Expanded] with its own scroll view inside, so the filters and the page
/// count stay put while the rows move under them — the same reasoning that
/// put the top bar outside the page.
///
/// Only the table is boxed. Wrapping the filters inside the same border
/// makes the screen read as one heavy object; leaving them outside lets the
/// border say exactly one thing — *here is the data*.
///
/// The wrapper is a [DecoratedSliver] rather than an [AppCard] around a list,
/// so the table inside it stays lazy. A catalogue of ten thousand titles must
/// not lay out ten thousand rows to draw a border.
class CollectionPageView<T> extends StatelessWidget {
  const CollectionPageView({
    required this.items,
    required this.columns,
    required this.emptyState,
    this.summary,
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

  /// A line about what the table holds — *1,284 titles*. It sits at the
  /// trailing end of the filter row, where a count belongs: beside the
  /// controls that change it.
  final String? summary;

  /// Search, filters and view controls, above the table.
  final Widget? toolbar;

  /// Anything above the filters — a row of stat tiles, a banner. Keep it
  /// short: every pixel here is a row the table cannot show.
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
    final count = summary;

    final tableWrapper = BoxDecoration(
      borderRadius: BorderRadius.circular(context.appRadius.container),
      border: Border.all(color: colors.hairline),
    );

    final table = items.isEmpty
        ? DecoratedBox(decoration: tableWrapper, child: emptyState)
        : DecoratedSliver(
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
            ),
          );

    final head = <Widget>[
      if (top != null) ...[top, SizedBox(height: spacing.lg)],
      if (bar != null || count != null) ...[
        _FilterBand(toolbar: bar, summary: count),
        SizedBox(height: spacing.sm),
      ],
    ];

    // A phone has no room to give the table a viewport of its own: the
    // filters alone would take half of it. There the whole page scrolls, as
    // it did before.
    if (context.formFactor.isCompact) {
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
                  for (final widget in head) SliverToBoxAdapter(child: widget),
                  if (items.isEmpty)
                    SliverToBoxAdapter(child: table)
                  else
                    table,
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

    return AppPageBody(
      wide: true,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.page,
          spacing.pageVertical,
          spacing.page,
          spacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...head,
            Expanded(
              child: items.isEmpty ? table : CustomScrollView(slivers: [table]),
            ),
            if (end != null) ...[
              SizedBox(height: spacing.xs),
              end,
            ],
          ],
        ),
      ),
    );
  }
}

/// The filter row, with the collection's count parked on its trailing edge.
class _FilterBand extends StatelessWidget {
  const _FilterBand({required this.toolbar, required this.summary});

  final Widget? toolbar;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final bar = toolbar;
    final count = summary;

    if (count == null) return bar ?? const SizedBox.shrink();

    final label = Text(
      count,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.appTextStyles.body.copyWith(
        color: context.appColors.mutedForeground,
      ),
    );

    if (bar == null) {
      return Align(alignment: AlignmentDirectional.centerStart, child: label);
    }

    return Row(
      children: [
        Expanded(child: bar),
        SizedBox(width: spacing.md),
        label,
      ],
    );
  }
}
