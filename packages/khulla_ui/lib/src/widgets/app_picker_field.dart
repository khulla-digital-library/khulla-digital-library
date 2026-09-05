import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_picker_field}
/// A field that looks like [AppTextField] but opens something instead of
/// taking keystrokes — a date picker, a member lookup, a shelf browser.
///
/// It takes an already-formatted [value] string. Formatting a date or an
/// amount is locale- and currency-dependent, and the design system does
/// neither: the caller formats, this lays out.
/// {@endtemplate}
class AppPickerField extends StatelessWidget {
  /// {@macro app_picker_field}
  const AppPickerField({
    required this.onTap,
    this.value,
    this.label,
    this.hintText,
    this.errorText,
    this.icon = AppIcons.chevronDown,
    this.required = false,
    this.enabled = true,
    this.onClear,
    this.clearTooltip,
    super.key,
  });

  /// Opens the picker. Null disables the field.
  final VoidCallback? onTap;

  /// The chosen value, already formatted. Null shows [hintText].
  final String? value;

  /// Label shown above the field.
  final String? label;

  /// Placeholder while nothing is chosen.
  ///
  /// Defaults to [label] when omitted so labelled fields always show a hint.
  final String? hintText;

  /// Validation message shown under the field.
  final String? errorText;

  /// Trailing glyph. Use `AppIcons.calendar` for a date,
  /// `AppIcons.search` for a lookup.
  final AppIconSpec icon;

  /// When true, the label shows a required asterisk.
  final bool required;

  /// Whether the field is interactive.
  final bool enabled;

  /// Clears the selection. Shows a clear button in place of [icon] once
  /// [value] is set.
  final VoidCallback? onClear;

  /// Tooltip on the clear button, required whenever [onClear] is set.
  final String? clearTooltip;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final fieldLabel = label;
    final hint = hintText ?? fieldLabel;
    final selected = value;
    final hasValue = selected != null && selected.isNotEmpty;
    final clear = onClear;
    final clearLabel = clearTooltip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldLabel != null) ...[
          AppFieldLabel(label: fieldLabel, required: required),
          SizedBox(height: spacing.xs),
        ],
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(context.appRadius.container),
          child: InputDecorator(
            isEmpty: !hasValue,
            decoration: InputDecoration(
              hintText: hint,
              errorText: errorText,
              enabled: enabled,
              suffixIcon: AppFieldAffix(
                child: hasValue && clear != null && clearLabel != null
                    ? AppIconButton(
                        icon: AppIcons.close,
                        tooltip: clearLabel,
                        onPressed: clear,
                      )
                    : AppIcon(
                        icon,
                        size: context.appMetrics.icon,
                        color: scheme.onSurfaceVariant,
                      ),
              ),
            ),
            child: hasValue
                ? Text(
                    selected,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: enabled
                          ? scheme.onSurface
                          : scheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
