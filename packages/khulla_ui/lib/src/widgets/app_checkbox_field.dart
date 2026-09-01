import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_checkbox_field}
/// A checkbox with its label and optional explanation, laid out as one row
/// that is entirely tappable.
///
/// The whole row is the target, not just the 20px box — a checkbox alone is
/// well under the 44px minimum and is the control people miss most.
/// {@endtemplate}
class AppCheckboxField extends StatelessWidget {
  /// {@macro app_checkbox_field}
  const AppCheckboxField({
    required this.value,
    required this.label,
    required this.onChanged,
    this.description,
    this.tristate = false,
    super.key,
  });

  /// Current state. Null is the indeterminate state when [tristate] is set.
  final bool? value;

  /// What ticking the box means.
  final String label;

  /// Called with the next state. Null disables the row.
  final ValueChanged<bool?>? onChanged;

  /// Supporting line under [label] — the consequence of ticking it.
  final String? description;

  /// Whether the box cycles through an indeterminate state.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final enabled = onChanged != null;
    final caption = description;

    return InkWell(
      onTap: enabled ? () => onChanged!(!(value ?? false)) : null,
      borderRadius: BorderRadius.circular(context.appRadius.control),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xxs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              tristate: tristate,
              onChanged: onChanged,
              visualDensity: VisualDensity.standard,
            ),
            SizedBox(width: spacing.xs),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: spacing.sm - spacing.xxs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: enabled
                            ? scheme.onSurface
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                    if (caption != null) ...[
                      SizedBox(height: spacing.xxs),
                      Text(
                        caption,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
