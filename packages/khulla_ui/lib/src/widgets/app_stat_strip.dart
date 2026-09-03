import 'package:khulla_ui/khulla_ui.dart';

/// A bounded row of figures drawn as **one** instrument panel.
///
/// Four separate cards with four separate borders and four separate shadows
/// is the shape every generated dashboard reaches for, and it says the
/// figures are four unrelated objects. They are not: they are one reading of
/// one collection, so they share one surface and are separated by the
/// hairline this product already uses for depth.
///
/// The strip lays out as many columns as the window class allows and wraps
/// the remainder onto further rows, drawing a divider between every cell in
/// both directions. Tiles are handed [AppStatTile.framed] as false, so a
/// caller passes the same tiles it would have put in an [AppResponsiveGrid].
class AppStatStrip extends StatelessWidget {
  const AppStatStrip({
    required this.tiles,
    this.compactColumns = 2,
    this.mediumColumns = 2,
    this.expandedColumns = 4,
    this.largeColumns = 4,
    super.key,
  });

  /// The figures, in reading order. Rendered unframed inside the strip.
  final List<AppStatTile> tiles;

  /// Columns below 600px. Two, not one: a figure and its label are short
  /// enough to pair on a phone, and a single column turns four figures into
  /// a scroll.
  final int compactColumns;

  /// Columns from 600px to 839px.
  final int mediumColumns;

  /// Columns from 840px to 1199px.
  final int expandedColumns;

  /// Columns at 1200px and above.
  final int largeColumns;

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) return const SizedBox.shrink();

    final colors = context.appColors;
    final scheme = context.colorScheme;
    final columns = context.formFactor.columns(
      compact: compactColumns,
      medium: mediumColumns,
      expanded: expandedColumns,
      large: largeColumns,
    );

    final rows = <List<AppStatTile>>[];
    for (var i = 0; i < tiles.length; i += columns) {
      rows.add(
        tiles.sublist(
          i,
          i + columns > tiles.length ? tiles.length : i + columns,
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(context.appRadius.container),
        border: Border.all(color: colors.hairlineStrong),
        boxShadow: context.appShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.appRadius.container),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (rowIndex, row) in rows.indexed) ...[
              if (rowIndex > 0) Divider(height: 1, color: colors.hairline),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (cell, tile) in row.indexed) ...[
                      if (cell > 0)
                        VerticalDivider(width: 1, color: colors.hairline),
                      Expanded(child: _unframed(tile)),
                    ],
                    // A short last row keeps its cells the width of the ones
                    // above rather than stretching to fill the strip, so the
                    // figures stay in their columns.
                    if (row.length < columns)
                      Expanded(
                        flex: columns - row.length,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static AppStatTile _unframed(AppStatTile tile) => AppStatTile(
    label: tile.label,
    value: tile.value,
    caption: tile.caption,
    icon: tile.icon,
    tone: tile.tone,
    trend: tile.trend,
    trendValue: tile.trendValue,
    trendInverted: tile.trendInverted,
    onTap: tile.onTap,
    isLoading: tile.isLoading,
    framed: false,
  );
}
