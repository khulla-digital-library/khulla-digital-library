import 'package:khulla_ui/khulla_ui.dart';

/// One row of an [AppTable] or [AppSliverTable].
///
/// Rows are separated by a **zebra stripe**, not by rules: at ~37px per row a
/// hairline every line turns a long table into a grid of boxes, while a 10%
/// tint on even rows reads as texture and lets the eye track across a 1600px
/// window. Hover and selection are tints of the same family, one step
/// stronger each, so the three states never compete.
///
/// The row's height is not fixed here — it comes from the cell padding token,
/// which is what keeps the table at the density the rest of the design
/// assumes.
class AppTableRow<T> extends StatefulWidget {
  const AppTableRow({
    required this.item,
    required this.columns,
    required this.index,
    this.onTap,
    this.selected = false,
    this.height,
    this.divided = false,
    super.key,
  });

  /// The record this row renders.
  final T item;

  /// Its position in the list, which decides whether it is striped.
  final int index;

  /// The full column set; the ones too wide for this window are dropped.
  final List<AppTableColumn<T>> columns;

  /// Opens the record. Null leaves the row inert.
  final VoidCallback? onTap;

  /// Whether this row is the picked one.
  final bool selected;

  /// The row's height. Uniform, so a lazy list can skip measuring. Null
  /// resolves to the density's row height.
  final double? height;

  /// Draws a hairline under the row. Off by default — the zebra stripe is
  /// the separator. Turn it on only for a short table inside a card, where
  /// there are too few rows for a stripe to read as a pattern.
  final bool divided;

  @override
  State<AppTableRow<T>> createState() => _AppTableRowState<T>();
}

class _AppTableRowState<T> extends State<AppTableRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final tints = colors.tints;
    final metrics = context.appMetrics;
    final visible = AppTableColumn.visible(widget.columns, context.formFactor);
    final interactive = widget.onTap != null;

    final fill = switch (null) {
      _ when widget.selected => tints.rowSelected,
      _ when _hovered && interactive => tints.rowHover,
      _ when widget.index.isOdd => tints.rowZebra,
      _ => Colors.transparent,
    };

    final content = ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: widget.height ?? metrics.tableHeaderHeight - 4,
      ),
      child: Row(
        children: [
          for (final column in visible)
            column.sized(
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: metrics.tableCellPaddingY,
                ),
                child: Align(
                  alignment: column.alignment,
                  child: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.appTextStyles.body.copyWith(
                      color: colors.ink100,
                    ),
                    child: column.cellBuilder(context, widget.item),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: context.appMotion.color,
        decoration: BoxDecoration(
          color: fill,
          border: widget.divided
              ? Border(bottom: BorderSide(color: colors.hairline))
              : null,
        ),
        child: interactive
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onTap,
                child: content,
              )
            : content,
      ),
    );
  }
}
