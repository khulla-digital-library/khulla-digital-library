import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_table_header}
/// The heading row of an [AppTable] — column labels, and sort controls on the
/// columns that have one.
///
/// It is a plain widget rather than part of the table so it can also be
/// pinned inside a [CustomScrollView], which is how [AppSliverTable] keeps
/// the headings on screen through a thousand rows.
/// {@endtemplate}
class AppTableHeader<T> extends StatelessWidget {
  /// {@macro app_table_header}
  const AppTableHeader({
    required this.columns,
    this.sort,
    this.onSort,
    this.height = 44,
    super.key,
  });

  /// The table's columns. Ones that do not fit the window are dropped here
  /// and in every row, so the two stay aligned.
  final List<AppTableColumn<T>> columns;

  /// The current ordering, or null while the table is unsorted.
  final AppTableSort? sort;

  /// Called with the next sort when a sortable heading is clicked. Null makes
  /// every heading inert, whatever the column says.
  final ValueChanged<AppTableSort>? onSort;

  /// Row height. Match it across header and rows so the grid lines up.
  final double height;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final visible = AppTableColumn.visible(columns, context.formFactor);
    final current = sort;
    final handler = onSort;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            for (final column in visible)
              column.sized(
                _HeaderCell<T>(
                  column: column,
                  sort: current,
                  onSort: column.sortable ? handler : null,
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCell<T> extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final current = sort;
    final isSorted = current != null && current.columnId == column.id;
    final handler = onSort;

    final label = Text(
      column.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: context.textTheme.labelMedium?.copyWith(
        color: isSorted ? scheme.primary : scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );

    final content = Align(
      alignment: column.alignment,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: label),
          if (isSorted) ...[
            SizedBox(width: spacing.xxs),
            Icon(
              current.ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: spacing.sm + 2,
              color: scheme.primary,
            ),
          ],
        ],
      ),
    );

    if (handler == null) {
      return Padding(padding: padding, child: content);
    }

    return InkWell(
      onTap: () => handler(
        current == null
            ? AppTableSort(columnId: column.id)
            : current.toggled(column.id),
      ),
      child: Padding(padding: padding, child: content),
    );
  }
}
