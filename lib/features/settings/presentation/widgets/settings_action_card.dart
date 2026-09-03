import 'package:khulla_ui/khulla_ui.dart';

/// One data operation: what it does, what it costs, and the control that
/// starts it.
///
/// [isDestructive] switches the button to the error role rather than moving
/// it somewhere different — the danger-zone card around it is what separates
/// it from the routine actions, and its own confirmation dialog is what stops
/// an accident.
class SettingsActionCard extends StatelessWidget {
  const SettingsActionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    required this.icon,
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final AppIconSpec icon;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final tone = isDestructive ? AppStatusTone.danger : AppStatusTone.brand;

    return AppCard(
      tone: isDestructive ? AppStatusTone.danger : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppIcon(icon, size: spacing.lg - 2, color: tone.foreground(context)),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  description,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: spacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: AppButton(
                    variant: AppButtonVariant.outline,
                    onPressed: onAction,
                    child: Text(actionLabel),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
