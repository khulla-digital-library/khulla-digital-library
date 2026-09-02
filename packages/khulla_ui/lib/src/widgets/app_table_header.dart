import 'package:khulla_ui/khulla_ui.dart';

/// The header row of an [AppTable] or [AppSliverTable].
///
/// Every sortable column shows its arrows at rest, muted, and lights the
/// active one: a header that only reveals sorting on hover is a control
/// nobody finds, and one that reveals it on click is a control nobody trusts.
///
/// Sorting is *reported*, never performed — see [AppTableSort].
class AppTableHeader<T> extends StatelessWidget {
  const AppTableHeader({
    required this.columns,
    this.sort,
    this.onSort,
    this.height = 44,
    super.key,
  });

  /// The full column set; the ones too wide for this window are dropped.
  final List<AppTableColumn<T>> columns;

  /// Which column the rows are ordered by, if any.
  final AppTableSort? sort;

  /// Called with the sort the user asked for. Null makes the header inert.
  final ValueChanged<AppTableSort>? onSort;

  /// The header's height.
  final double height;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final visible = AppTableColumn.visible(columns, context.formFactor);
    final current = sort;
    final handler = onSort;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: colors.hairline)),
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
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final current = sort;
    final isSorted = current != null && current.columnId == column.id;
    final handler = onSort;

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
              style: context.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                color: isSorted ? colors.textHigh : colors.textMuted,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
          if (handler != null)
            _SortGlyphs(
              ascending: isSorted ? current.ascending : null,
              active: scheme.primary,
              rest: colors.hairlineStrong,
            ),
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
          Icon(
            Icons.arrow_drop_up_rounded,
            size: 14,
            color: direction ?? false ? active : rest,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Icon(
              Icons.arrow_drop_down_rounded,
              size: 14,
              color: direction == false ? active : rest,
            ),
          ),
        ],
      ),
    );
  }
}
