import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_switch_field}
/// A setting row: label, explanation, and a switch on the trailing edge.
///
/// A switch means the change takes effect immediately — that is what
/// separates it from [AppCheckboxField], which collects a value the form
/// submits later. Use it in Settings, not in an editor.
/// {@endtemplate}
class AppSwitchField extends StatelessWidget {
  /// {@macro app_switch_field}
  const AppSwitchField({
    required this.value,
    required this.label,
    required this.onChanged,
    this.description,
    super.key,
  });

  /// Whether the setting is on.
  final bool value;

  /// What the setting does.
  final String label;

  /// Called with the next state. Null disables the row.
  final ValueChanged<bool>? onChanged;

  /// Supporting line under [label].
  final String? description;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final enabled = onChanged != null;
    final caption = description;

    return InkWell(
      onTap: enabled ? () => onChanged!(!value) : null,
      borderRadius: BorderRadius.circular(context.appRadius.control),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Row(
          children: [
            Expanded(
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
                      fontWeight: FontWeight.w500,
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
            SizedBox(width: spacing.md),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
