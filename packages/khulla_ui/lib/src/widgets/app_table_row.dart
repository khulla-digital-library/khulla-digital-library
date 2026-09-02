import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_table_row}
/// One record's row in an [AppTable], built from the same column list as the
/// header so the two stay aligned at every window size.
///
/// The row carries hover and focus feedback, because on a desk tool a row is
/// usually the target — clicking anywhere in it opens the record — and a
/// pointer needs to see what it is about to open.
/// {@endtemplate}
class AppTableRow<T> extends StatelessWidget {
  /// {@macro app_table_row}
  const AppTableRow({
    required this.item,
    required this.columns,
    this.onTap,
    this.selected = false,
    this.height = 52,
    this.divided = true,
    super.key,
  });

  /// The record this row shows.
  final T item;

  /// The table's columns. Ones too wide for the window are dropped.
  final List<AppTableColumn<T>> columns;

  /// Opens the record. Null makes the row inert — correct for a read-only
  /// summary table, wrong for a catalogue.
  final VoidCallback? onTap;

  /// Marks the row as the one shown in the detail pane beside the table.
  final bool selected;

  /// Row height. Fixed rather than intrinsic so the list can skip measuring:
  /// [AppSliverTable] passes it as an `itemExtent`.
  final double height;

  /// Whether to draw the hairline under the row.
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final visible = AppTableColumn.visible(columns, context.formFactor);

    final content = SizedBox(
      height: height,
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
                    style: context.textTheme.bodyMedium ?? const TextStyle(),
                    child: column.cellBuilder(context, item),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.07),
                scheme.surface,
              )
            : scheme.surface,
        border: divided
            ? Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.4),
                ),
              )
            : null,
      ),
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              hoverColor: scheme.primary.withValues(alpha: 0.04),
              focusColor: scheme.primary.withValues(alpha: 0.08),
              child: content,
            ),
    );
  }
}
