import 'package:khulla_ui/khulla_ui.dart';

/// The header row of an [AppTable] or [AppSliverTable].
///
/// A tinted band rather than a filled bar: the header is 5% of the meta ink
/// over the page, which separates it from the rows without introducing a
/// second surface color.
///
/// A sorted column keeps its glyph visible; an unsorted sortable column
/// reveals it on hover, so a twelve-column table is not a wall of arrows.
///
/// Sorting is *reported*, never performed — see [AppTableSort].
class AppTableHeader<T> extends StatelessWidget {
  const AppTableHeader({
    required this.columns,
    this.sort,
    this.onSort,
    this.height,
    super.key,
  });

  /// The full column set; the ones too wide for this window are dropped.
  final List<AppTableColumn<T>> columns;

  /// Which column the rows are ordered by, if any.
  final AppTableSort? sort;

  /// Called with the sort the user asked for. Null makes the header inert.
  final ValueChanged<AppTableSort>? onSort;

  /// The header's height. Null resolves to the density's header height.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final visible = AppTableColumn.visible(columns, context.formFactor);
    final current = sort;
    final handler = onSort;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.tints.tableHeader,
        border: Border(bottom: BorderSide(color: colors.hairline)),
      ),
      child: SizedBox(
        height: height ?? context.appMetrics.tableHeaderHeight,
        child: Row(
          children: [
            for (final column in visible)
              column.sized(
                _HeaderCell<T>(
                  column: column,
                  sort: current,
                  onSort: column.sortable ? handler : null,
                  padding: EdgeInsets.symmetric(horizontal: spacing.md),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell<T> extends StatefulWidget {
  const _HeaderCell({
    required this.column,
    required this.sort,
    required this.onSort,
    required this.padding,
  });

  final AppTableColumn<T> column;
  final AppTableSort? sort;
  final ValueChanged<AppTableSort>? onSort;
  final EdgeInsets padding;

  @override
  State<_HeaderCell<T>> createState() => _HeaderCellState<T>();
}

class _HeaderCellState<T> extends State<_HeaderCell<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final column = widget.column;
    final padding = widget.padding;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final current = widget.sort;
    final isSorted = current != null && current.columnId == column.id;
    final handler = widget.onSort;

    final content = Align(
      alignment: column.alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              column.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.appTextStyles.columnHeader.copyWith(
                color: isSorted ? colors.ink100 : colors.ink500,
              ),
            ),
          ),
          if (handler != null)
            AnimatedOpacity(
              duration: context.appMotion.color,
              opacity: isSorted || _hovered ? 1 : 0,
              child: _SortGlyphs(
                ascending: isSorted ? current.ascending : null,
                active: scheme.primary,
                rest: colors.hairlineStrong,
              ),
            ),
        ],
      ),
    );

    if (handler == null) {
      return Padding(padding: padding, child: content);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => handler(
          current == null
              ? AppTableSort(columnId: column.id)
              : current.toggled(column.id),
        ),
        child: Padding(padding: padding, child: content),
      ),
    );
  }
}

/// The stacked up/down carets beside a sortable column's label.
class _SortGlyphs extends StatelessWidget {
  const _SortGlyphs({
    required this.ascending,
    required this.active,
    required this.rest,
  });

  /// Null when this column is not the sorted one.
  final bool? ascending;
  final Color active;
  final Color rest;

  @override
  Widget build(BuildContext context) {
    final direction = ascending;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppIcons.caretUp,
            size: 14,
            color: direction ?? false ? active : rest,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AppIcon(
              AppIcons.caretDown,
              size: 14,
              color: direction == false ? active : rest,
            ),
          ),
        ],
      ),
    );
  }
}
