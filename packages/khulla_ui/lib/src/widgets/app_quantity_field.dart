import 'dart:async';

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
/// The value is typed or stepped. Stepping slides the figure with
/// [AppSlidingNumber]. [AppPositiveIntFormatter] keeps it a non-negative
/// integer; [min] is enforced by disabling minus and by the caller on submit,
/// not by rewriting a cleared field mid-gesture.
/// {@endtemplate}
class AppQuantityField extends StatefulWidget {
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

  @override
  State<AppQuantityField> createState() => _AppQuantityFieldState();
}

class _AppQuantityFieldState extends State<AppQuantityField> {
  late final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  int? _parsed(String text) => int.tryParse(text);

  void _step(int delta) {
    final current = _parsed(widget.controller.text);
    final next = (current ?? (delta > 0 ? widget.min - 1 : widget.min + 1)) +
        delta;
    final clamped = next.clamp(widget.min, widget.max);
    final text = clamped.toString();
    _focus.unfocus();
    unawaited(HapticFeedback.selectionClick());
    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final numeric = context.appTextStyles.numeric.copyWith(color: colors.ink100);
    final error = widget.errorText;
    final fieldLabel = widget.label;
    final width = metrics.fieldHeight * 3;
    final focused = _focus.hasFocus;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fieldLabel != null) ...[
            AppFieldLabel(
              label: fieldLabel,
              required: widget.required,
              hasError: error != null,
            ),
            SizedBox(height: metrics.labelToControlGap),
          ],
          ConstrainedBox(
            key: const ValueKey('app_quantity_control'),
            constraints: BoxConstraints.tightFor(height: metrics.fieldHeight),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.appRadius.container),
                border: Border.all(
                  color: colors.hairline,
                  width: context.appBorders.hairline,
                ),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) {
                  final parsed = _parsed(value.text);
                  final canDecrease =
                      widget.enabled && parsed != null && parsed > widget.min;
                  final canIncrease =
                      widget.enabled && (parsed == null || parsed < widget.max);
                  final showSlide = !focused && parsed != null;

                  return Row(
                    children: [
                      AppIconButton(
                        icon: AppIcons.remove,
                        tooltip: widget.decreaseTooltip,
                        size: AppIconButtonSize.small,
                        onPressed: canDecrease ? () => _step(-1) : null,
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            TextField(
                              controller: widget.controller,
                              focusNode: _focus,
                              enabled: widget.enabled,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                AppPositiveIntFormatter(max: widget.max),
                              ],
                              style: numeric.copyWith(
                                color: showSlide
                                    ? Colors.transparent
                                    : colors.ink100,
                              ),
                              cursorColor: colors.ink100,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                counterText: '',
                              ),
                              onChanged: widget.onChanged,
                            ),
                            if (showSlide)
                              IgnorePointer(
                                child: AppSlidingNumber(
                                  value: parsed,
                                  style: numeric,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: AppIcons.add,
                        tooltip: widget.increaseTooltip,
                        size: AppIconButtonSize.small,
                        onPressed: canIncrease ? () => _step(1) : null,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (error != null) ...[
            SizedBox(height: spacing.xxs + 2),
            AppFieldError(message: error),
          ],
        ],
      ),
    );
  }
}
