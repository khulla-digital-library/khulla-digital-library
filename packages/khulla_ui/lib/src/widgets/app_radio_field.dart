import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_radio_field}
/// One choice in a mutually-exclusive group, with its label and an optional
/// explanation, laid out as one tappable row.
///
/// A radio is for a choice the form submits later and where the options need
/// to stay visible — a loan period, a label size. Where exactly one option
/// must be active and there are four or fewer, [AppSegmentedControl] says the
/// same thing in a quarter of the height; where the set is long or
/// data-driven, [AppDropdownField] does.
/// {@endtemplate}
class AppRadioField<T> extends StatelessWidget {
  /// {@macro app_radio_field}
  const AppRadioField({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.description,
    super.key,
  });

  /// The choice this row represents.
  final T value;

  /// The group's current choice.
  final T? groupValue;

  /// What picking this choice means.
  final String label;

  /// Called with [value] when the row is picked. Null disables the row.
  final ValueChanged<T>? onChanged;

  /// Supporting line under [label].
  final String? description;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final selected = value == groupValue;
    final enabled = onChanged != null;
    final caption = description;

    return AppRipple(
      onTap: enabled ? () => onChanged!(value) : null,
      borderRadius: BorderRadius.circular(context.appRadius.container),
      pressScale: 1,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioMark(selected: selected, size: metrics.checkbox),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: context.appTextStyles.body.copyWith(
                      color: enabled ? colors.ink100 : colors.ink500,
                    ),
                  ),
                  if (caption != null) ...[
                    SizedBox(height: spacing.xxs),
                    Text(
                      caption,
                      style: context.appTextStyles.caption.copyWith(
                        color: colors.mutedForeground,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The ring and its dot. Hand-drawn rather than Material's `Radio` so it can
/// match the checkbox's 16px box and 1.5px stroke, and so the dot can spring
/// in rather than fade.
class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.size});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final motion = context.appMotion;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? colors.brand : colors.hairlineStrong,
            width: context.appBorders.checkbox,
          ),
        ),
        child: Center(
          child: AnimatedScale(
            duration: motion.overlay,
            curve: Curves.elasticOut,
            scale: selected ? 1 : 0,
            child: Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.brand,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
