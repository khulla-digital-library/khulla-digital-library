import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_segmented_control}
/// A small set of mutually exclusive choices, all visible at once — *All /
/// On loan / Overdue*, or a list/grid view switch.
///
/// Use it up to about four choices where the options matter enough to stay on
/// screen. Past that, or where the set is data-driven, use
/// [AppDropdownField]. It is built on Material's `SegmentedButton`, so
/// keyboard traversal and screen-reader grouping come for free.
/// {@endtemplate}
class AppSegmentedControl<T> extends StatelessWidget {
  /// {@macro app_segmented_control}
  const AppSegmentedControl({
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.itemIcon,
    this.showSelectedIcon = false,
    super.key,
  });

  /// The active choice.
  final T value;

  /// The choices, in display order.
  final List<T> items;

  /// Turns a choice into its localized label.
  final String Function(T value) itemLabel;

  /// Called with the new choice.
  final ValueChanged<T> onChanged;

  /// Optional per-choice glyph.
  final IconData? Function(T value)? itemIcon;

  /// Whether the selected segment shows a check mark. Off by default: the
  /// fill already says which one is active, and the tick costs width.
  final bool showSelectedIcon;

  Widget? _iconFor(T item) {
    final glyph = itemIcon?.call(item);
    return glyph == null ? null : Icon(glyph);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return SegmentedButton<T>(
      segments: [
        for (final item in items)
          ButtonSegment<T>(
            value: item,
            label: Text(itemLabel(item)),
            icon: _iconFor(item),
          ),
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: showSelectedIcon,
      style: ButtonStyle(
        visualDensity: VisualDensity.standard,
        textStyle: WidgetStatePropertyAll(
          context.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: spacing.sm, vertical: spacing.xs),
        ),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.appRadius.field),
          ),
        ),
      ),
    );
  }
}
