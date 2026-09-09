import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_swatch_picker}
/// A row of color choices, one of them active.
///
/// The color *is* the label, so each swatch is a plain filled circle and the
/// name is only a tooltip — a grid of named rows would make picking a color a
/// reading task. Selection is a ring drawn outside the swatch plus a tick on
/// it: a ring alone disappears on a pale color, a tick alone disappears on a
/// dark one.
///
/// Use for a small, fixed set of colors. Anything data-driven or longer than
/// about a dozen belongs in a dropdown.
/// {@endtemplate}
class AppSwatchPicker<T> extends StatelessWidget {
  /// {@macro app_swatch_picker}
  const AppSwatchPicker({
    required this.value,
    required this.items,
    required this.itemColor,
    required this.itemLabel,
    required this.onChanged,
    super.key,
  });

  /// The active choice.
  final T value;

  /// The choices, in display order.
  final List<T> items;

  /// The color each choice paints.
  final Color Function(T value) itemColor;

  /// Turns a choice into its localized name, shown as a tooltip.
  final String Function(T value) itemLabel;

  /// Called with the new choice.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Wrap(
      spacing: spacing.sm,
      runSpacing: spacing.sm,
      children: [
        for (final item in items)
          _Swatch(
            color: itemColor(item),
            label: itemLabel(item),
            selected: item == value,
            onTap: () => onChanged(item),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const double _size = 32;
  static const double _ring = 2;
  static const double _gap = 3;

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final motion = context.appMotion;
    // White on a dark swatch, near-black on a pale one — the same rule the
    // brand ramp uses for the ink on a primary fill.
    final tick = color.computeLuminance() > 0.45
        ? colors.textHigh
        : colors.onSuccess;

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: AppRipple(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_size),
          child: AnimatedContainer(
            duration: motion.color,
            padding: const EdgeInsets.all(_gap),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: _ring,
              ),
            ),
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: selected
                  ? Center(
                      child: AppIcon(
                        AppIcons.check,
                        size: context.appMetrics.iconInButton,
                        color: tick,
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
