import 'package:khulla_ui/khulla_ui.dart';

/// A share of a whole, as a labelled track: shelf capacity, a category's
/// slice of the catalogue, how much of a fine has been paid.
///
/// It takes a [value] already reduced to 0–1 and a ready-made [valueLabel],
/// because turning "312 of 1,240" into a percentage is a rounding decision
/// with a locale in it, and neither belongs in a painter.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    this.label,
    this.valueLabel,
    this.tone = AppStatusTone.brand,
    this.thickness = 8,
    super.key,
  });

  /// The filled share, clamped to 0–1.
  final double value;

  /// What the bar measures.
  final String? label;

  /// The figure shown at the trailing edge of the label row.
  final String? valueLabel;

  /// Which tone fills the track.
  final AppStatusTone tone;

  /// The track's height.
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final caption = label;
    final figure = valueLabel;
    final radius = BorderRadius.circular(thickness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (caption != null || figure != null) ...[
          Row(
            children: [
              if (caption != null)
                Expanded(
                  child: Text(
                    caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ),
              if (figure != null)
                Text(
                  figure,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textHigh,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.xs),
        ],
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: thickness,
            child: Stack(
              children: [
                ColoredBox(
                  color: colors.neutralSoft,
                  child: const SizedBox.expand(),
                ),
                FractionallySizedBox(
                  widthFactor: value.clamp(0, 1).toDouble(),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: tone.foreground(context),
                      borderRadius: radius,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
