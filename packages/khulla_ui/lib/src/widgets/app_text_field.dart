import 'package:flutter/services.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_text_field}
/// A text field with an external label and onboarding-style decoration.
/// {@endtemplate}
class AppTextField extends StatelessWidget {
  /// {@macro app_text_field}
  const AppTextField({
    required this.onChanged,
    super.key,
    this.label,
    this.hintText,
    this.errorText,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.suffixIcon,
    this.textInputAction,
    this.initialValue,
    this.controller,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.enabled = true,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
    this.showCursor,
    this.enableInteractiveSelection = true,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  /// External label shown above the field. Omit for hint-only fields (e.g. search).
  final String? label;

  /// Placeholder shown inside the field while empty.
  final String? hintText;

  /// Called on every keystroke.
  final ValueChanged<String> onChanged;

  /// Validation message shown under the field.
  final String? errorText;

  /// When true, the external label shows a required asterisk.
  final bool required;

  /// Soft keyboard type.
  final TextInputType? keyboardType;

  /// Whether the value is masked.
  final bool obscureText;

  /// Leading adornment.
  final Widget? prefixIcon;

  /// Size constraints for [prefixIcon]. Tighten when the prefix is text.
  final BoxConstraints? prefixIconConstraints;

  /// Trailing adornment.
  final Widget? suffixIcon;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Starting value for an uncontrolled field.
  final String? initialValue;

  /// External controller for a field whose text is driven by the caller.
  final TextEditingController? controller;

  /// Maximum character count. The counter itself stays hidden.
  final int? maxLength;

  /// Maximum visible lines. Pass null for an unbounded, growing field.
  final int? maxLines;

  /// Minimum visible lines.
  final int? minLines;

  /// Input masking or filtering.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether the field accepts input.
  final bool enabled;

  /// Whether the field takes focus on first build.
  final bool autofocus;

  /// Auto-capitalization behavior of the soft keyboard.
  final TextCapitalization textCapitalization;

  /// Called when the keyboard action button is pressed.
  final ValueChanged<String>? onSubmitted;

  /// Optional focus node for keyboard traversal between fields.
  final FocusNode? focusNode;

  /// When true, the field is not editable (e.g. tap-to-navigate search entry).
  final bool readOnly;

  /// Called when the field is tapped. Useful with [readOnly] search affordances.
  final VoidCallback? onTap;

  /// Overrides cursor visibility. Defaults to hidden for [readOnly] tap fields.
  final bool? showCursor;

  /// Whether the field text can be selected. Defaults to false for [readOnly]
  /// tap fields.
  final bool enableInteractiveSelection;

  /// Vertical extent of the decorated field body (no external label).
  static double heightOf(AppSpacing spacing) {
    // Prefix/suffix icons use the standard 48px Material touch target.
    return spacing.lg + spacing.lg;
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final fieldLabel = label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldLabel != null) ...[
          AppFieldLabel(label: fieldLabel, required: required),
          SizedBox(height: spacing.xs),
        ],
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          focusNode: focusNode,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          showCursor: showCursor ?? (!readOnly && onTap == null),
          enableInteractiveSelection:
              !(readOnly && onTap != null) && enableInteractiveSelection,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: minLines,
          inputFormatters: inputFormatters,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            errorStyle: context.textTheme.bodySmall?.copyWith(
              color: scheme.error,
              fontWeight: FontWeight.normal,
            ),
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
        ),
      ],
    );
  }
}
