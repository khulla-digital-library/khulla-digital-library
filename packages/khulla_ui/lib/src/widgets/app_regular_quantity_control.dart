import 'package:khulla_ui/khulla_ui.dart';

/// The full-height minus/plus control behind [AppQuantityField] at
/// [AppQuantityFieldSize.regular]: a text field with affixed stepper buttons
/// and the sliding figure overlaid while unfocused.
///
/// Tokens are read from context; only the value, bounds, tooltips and
/// callbacks arrive as parameters.
class AppRegularQuantityControl extends StatelessWidget {
  const AppRegularQuantityControl({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.max,
    required this.numeric,
    required this.canDecrease,
    required this.canIncrease,
    required this.showSlide,
    required this.parsed,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    required this.onChanged,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final int max;
  final TextStyle numeric;
  final bool canDecrease;
  final bool canIncrease;
  final bool showSlide;
  final int? parsed;
  final String decreaseTooltip;
  final String increaseTooltip;
  final ValueChanged<String> onChanged;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final controlHeight = metrics.fieldHeight;
    final iconSlot = BoxConstraints(
      minWidth: metrics.iconButtonSmall,
      maxWidth: metrics.iconButtonSmall,
      maxHeight: controlHeight,
    );

    return ConstrainedBox(
      key: const ValueKey('app_quantity_control'),
      constraints: BoxConstraints(
        minHeight: controlHeight,
        maxHeight: controlHeight,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [AppPositiveIntFormatter(max: max)],
            style: numeric.copyWith(
              color: showSlide ? Colors.transparent : colors.ink100,
            ),
            decoration: InputDecoration(
              prefixIcon: AppFieldAffix(
                child: AppIconButton(
                  icon: AppIcons.remove,
                  tooltip: decreaseTooltip,
                  size: AppIconButtonSize.small,
                  onPressed: canDecrease ? onDecrease : null,
                ),
              ),
              suffixIcon: AppFieldAffix(
                child: AppIconButton(
                  icon: AppIcons.add,
                  tooltip: increaseTooltip,
                  size: AppIconButtonSize.small,
                  onPressed: canIncrease ? onIncrease : null,
                ),
              ),
              prefixIconConstraints: iconSlot,
              suffixIconConstraints: iconSlot,
              counterText: '',
              contentPadding: EdgeInsetsDirectional.only(
                start: spacing.sm,
                end: spacing.sm,
                top: spacing.xs,
                bottom: spacing.xs,
              ),
            ),
            onChanged: onChanged,
          ),
          if (showSlide)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: metrics.iconButtonSmall,
              ),
              child: IgnorePointer(
                child: AppSlidingNumber(
                  value: parsed!,
                  style: numeric,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
