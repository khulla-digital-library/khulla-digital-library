import 'package:khulla_ui/khulla_ui.dart';

/// One row of an [AppTable] or [AppSliverTable].
///
/// Rows are separated by a hairline, not by stripes: zebra striping fights
/// the status washes the cells carry, and on a catalogue every other row
/// carries one. Hover tints the whole row so a pointer never loses which line
/// it is on halfway across a 1600px window.
class AppTableRow<T> extends StatefulWidget {
  const AppTableRow({
    required this.item,
    required this.columns,
    this.onTap,
    this.selected = false,
    this.height = 60,
    this.divided = true,
    super.key,
  });

  /// The record this row renders.
  final T item;

  /// The full column set; the ones too wide for this window are dropped.
  final List<AppTableColumn<T>> columns;

  /// Opens the record. Null leaves the row inert.
  final VoidCallback? onTap;

  /// Whether this row is the picked one.
  final bool selected;

  /// The row's height. Uniform, so the list can skip measuring.
  final double height;

  /// Whether to draw the hairline under the row.
  final bool divided;

  @override
  State<AppTableRow<T>> createState() => _AppTableRowState<T>();
}

class _AppTableRowState<T> extends State<AppTableRow<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final visible = AppTableColumn.visible(widget.columns, context.formFactor);
    final interactive = widget.onTap != null;

    final fill = switch (null) {
      _ when widget.selected => colors.brandSoft,
      _ when _hovered && interactive => scheme.surfaceContainerLow,
      _ => scheme.surface,
    };

    final content = SizedBox(
      height: widget.height,
      child: Row(
        children: [
          for (final column in visible)
            column.sized(
              Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                child: Align(
                  alignment: column.alignment,
                  child: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        context.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurface,
                        ) ??
                        const TextStyle(),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          border: widget.divided
              ? Border(bottom: BorderSide(color: colors.hairline))
              : null,
        ),
        child: interactive
            ? InkWell(
                onTap: widget.onTap,
                hoverColor: Colors.transparent,
                focusColor: scheme.primary.withValues(alpha: 0.06),
                child: content,
              )
            : content,
      ),
    );
  }
}
