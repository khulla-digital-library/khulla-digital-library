import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_dropdown_field}
/// A labelled select, decorated to match [AppTextField] so a form of mixed
/// controls lines up.
///
/// Generic over the value so a caller keeps its own enum or domain type all
/// the way to `onChanged` — no string round trip, no parsing back. [itemLabel]
/// is how a value becomes text, which keeps localization on the app side.
/// {@endtemplate}
class AppDropdownField<T> extends StatelessWidget {
  /// {@macro app_dropdown_field}
  const AppDropdownField({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.label,
    this.hintText,
    this.errorText,
    this.required = false,
    this.enabled = true,
    this.itemIcon,
    super.key,
  });

  /// The current selection. Null shows [hintText].
  final T? value;

  /// The choices, in display order.
  final List<T> items;

  /// Turns a choice into its localized label.
  final String Function(T value) itemLabel;

  /// Called when a choice is made.
  final ValueChanged<T?> onChanged;

  /// Label shown above the control.
  final String? label;

  /// Placeholder while nothing is selected.
  final String? hintText;

  /// Validation message shown under the control.
  final String? errorText;

  /// When true, the label shows a required asterisk.
  final bool required;

  /// Whether the control accepts input.
  final bool enabled;

  /// Optional per-choice glyph — a status dot, a format icon.
  final IconData? Function(T value)? itemIcon;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final fieldLabel = label;
    final iconFor = itemIcon;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldLabel != null) ...[
          AppFieldLabel(label: fieldLabel, required: required),
          SizedBox(height: spacing.xs),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          borderRadius: BorderRadius.circular(context.appRadius.field),
          icon: Icon(
            Icons.expand_more_rounded,
            color: scheme.onSurfaceVariant,
            size: spacing.md + 4,
          ),
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            enabled: enabled,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Row(
                  children: [
                    if (iconFor?.call(item) case final glyph?) ...[
                      Icon(
                        glyph,
                        size: spacing.md,
                        color: scheme.onSurfaceVariant,
                      ),
                      SizedBox(width: spacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        itemLabel(item),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
