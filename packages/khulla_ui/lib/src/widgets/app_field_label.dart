import 'package:khulla_ui/khulla_ui.dart';

/// Label shown above form controls such as [AppTextField].
class AppFieldLabel extends StatelessWidget {
  /// {@macro app_field_label}
  const AppFieldLabel({required this.label, this.required = false, super.key});

  /// Field label text.
  final String label;

  /// When true, appends a red asterisk to signal a required field.
  final bool required;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: label,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          if (required)
            TextSpan(
              text: ' *',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: scheme.error,
              ),
            ),
        ],
      ),
    );
  }
}
