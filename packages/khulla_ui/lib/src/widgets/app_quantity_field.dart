import 'package:flutter/services.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Digits-only whole numbers, capped at [max], with leading zeros stripped.
///
/// Empty is allowed so the field can be cleared and retyped. A lone `0` is
/// kept so the caller can show a validation error instead of silently
/// rewriting the value.
class AppPositiveIntFormatter extends TextInputFormatter {
  /// Creates a formatter that accepts `''` or an integer in `0…max`.
  const AppPositiveIntFormatter({this.max = 999});

  /// Inclusive upper bound. Edits that would exceed it are rejected.
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    if (raw.isEmpty) return newValue;
    if (!RegExp(r'^\d+$').hasMatch(raw)) return oldValue;
    final parsed = int.parse(raw);
    if (parsed > max) return oldValue;
    final normalized = parsed.toString();
    if (normalized == raw) return newValue;
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

/// {@template app_quantity_field}
/// A whole-number field with minus and plus at the ends.
///
/// The value is typed or stepped. [AppPositiveIntFormatter] keeps it a
/// non-negative integer; [min] is enforced by disabling minus and by the
/// caller on submit, not by rewriting a cleared field mid-gesture.
/// {@endtemplate}
class AppQuantityField extends StatelessWidget {
  /// {@macro app_quantity_field}
  const AppQuantityField({
    required this.onChanged,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    required this.controller,
    super.key,
    this.label,
    this.errorText,
    this.required = false,
    this.min = 1,
    this.max = 999,
    this.enabled = true,
  });

  /// External label shown above the field.
  final String? label;

  /// Validation message shown under the field.
  final String? errorText;

  /// When true, the external label shows a required asterisk.
  final bool required;

  /// Called on every keystroke and after a step.
  final ValueChanged<String> onChanged;

  /// Localized tooltip for the minus control.
  final String decreaseTooltip;

  /// Localized tooltip for the plus control.
  final String increaseTooltip;

  /// The value. The stepper writes through this same controller.
  final TextEditingController controller;

  /// Inclusive lower bound for the stepper. Typing below it is still
  /// possible so the field can show [errorText].
  final int min;

  /// Inclusive upper bound for typing and the stepper.
  final int max;

  /// Whether the field accepts input.
  final bool enabled;

  int? _parsed(String text) => int.tryParse(text);

  void _step(TextEditingController field, int delta) {
    final current = _parsed(field.text);
    final next = (current ?? (delta > 0 ? min - 1 : min + 1)) + delta;
    final clamped = next.clamp(min, max);
    final text = clamped.toString();
    field.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final metrics = context.appMetrics;
    final slot = BoxConstraints(
      minWidth: metrics.iconButtonSmall,
      maxWidth: metrics.iconButtonSmall,
      minHeight: 0,
      maxHeight: metrics.fieldHeight,
    );
    final width = metrics.fieldHeight * 3;

    return SizedBox(
      width: width,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, _, _) {
          final value = _parsed(controller.text);
          final canDecrease = enabled && value != null && value > min;
          final canIncrease = enabled && (value == null || value < max);

          return AppTextField(
            label: label,
            required: required,
            errorText: errorText,
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [AppPositiveIntFormatter(max: max)],
            prefixIconConstraints: slot,
            suffixIconConstraints: slot,
            prefixIcon: AppIconButton(
              icon: AppIcons.remove,
              tooltip: decreaseTooltip,
              size: AppIconButtonSize.small,
              onPressed: canDecrease ? () => _step(controller, -1) : null,
            ),
            suffixIcon: AppIconButton(
              icon: AppIcons.add,
              tooltip: increaseTooltip,
              size: AppIconButtonSize.small,
              onPressed: canIncrease ? () => _step(controller, 1) : null,
            ),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
