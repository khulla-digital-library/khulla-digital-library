import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_dialog}
/// Shared modal dialog chrome: a centered card with an optional icon badge,
/// a title, a message, and an [actions] slot for a button row or column.
///
/// Use [AppDialog.show] to present arbitrary content in this chrome, or
/// [AppDialog.confirmDestructive] for the common "delete this?" prompt.
/// {@endtemplate}
class AppDialog extends StatelessWidget {
  /// {@macro app_dialog}
  const AppDialog({
    required this.title,
    required this.message,
    required this.actions,
    this.icon,
    this.iconWidget,
    this.iconColor,
    this.iconBackgroundColor,
    super.key,
  });

  final String title;
  final String message;

  /// Icon shown in a tinted circular badge above the title. Omit for a
  /// dialog with no badge.
  final IconData? icon;

  /// Custom badge glyph when [icon] is not enough (e.g. an SVG asset).
  /// Takes precedence over [icon] when both are set.
  final Widget? iconWidget;

  /// Glyph color for [icon]. Defaults to [ColorScheme.error].
  final Color? iconColor;

  /// Fill color for the badge behind [icon]. Defaults to
  /// [ColorScheme.errorContainer].
  final Color? iconBackgroundColor;

  /// Button row or column, typically built with [AppDialog.destructiveAction]
  /// and [AppDialog.secondaryAction].
  final Widget actions;

  /// Presents [AppDialog] and resolves to whatever the dialog is popped with.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String message,
    required WidgetBuilder actionsBuilder,
    IconData? icon,
    Widget? iconWidget,
    Color? iconColor,
    Color? iconBackgroundColor,
    bool barrierDismissible = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => AppDialog(
      title: title,
      message: message,
      icon: iconWidget == null ? icon : null,
      iconWidget: iconWidget,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      actions: Builder(builder: actionsBuilder),
    ),
  );

  /// Confirms a destructive action (delete, remove, discard). Resolves to
  /// true only when the destructive [confirmLabel] button is tapped.
  static Future<bool> confirmDestructive({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    IconData? icon = Icons.delete_outline_rounded,
    Widget? iconWidget,
  }) async {
    final confirmed = await show<bool>(
      context: context,
      title: title,
      message: message,
      icon: iconWidget == null ? icon : null,
      iconWidget: iconWidget,
      actionsBuilder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialog.destructiveAction(
            context: dialogContext,
            label: confirmLabel,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
          SizedBox(height: dialogContext.appSpacing.xs),
          AppDialog.secondaryAction(
            context: dialogContext,
            label: cancelLabel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Full-width filled button in [ColorScheme.error], for the destructive
  /// choice in a confirmation dialog's [actions].
  static Widget destructiveAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    final scheme = context.colorScheme;
    return SizedBox(
      width: double.infinity,
      child: AppFilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.error),
          foregroundColor: WidgetStatePropertyAll(scheme.onError),
          minimumSize: WidgetStatePropertyAll(
            Size(0, context.appSpacing.xlg + context.appSpacing.xxs),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  /// Full-width outlined button, for the cancel/dismiss choice in a
  /// confirmation dialog's [actions].
  static Widget secondaryAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AppOutlinedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(0, context.appSpacing.xlg + context.appSpacing.xxs),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final badgeIcon =
        iconWidget ??
        (icon == null
            ? null
            : Icon(icon, color: iconColor ?? scheme.error, size: spacing.lg));

    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.appRadius.card),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: spacing.lg,
        vertical: spacing.xlg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            spacing.lg,
            spacing.xlg,
            spacing.lg,
            spacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (badgeIcon != null) ...[
                Center(
                  child: Container(
                    width: spacing.xlg + spacing.md,
                    height: spacing.xlg + spacing.md,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor ?? scheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: badgeIcon,
                  ),
                ),
                SizedBox(height: spacing.md),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.2,
                  color: scheme.onSurface,
                ),
              ),
              SizedBox(height: spacing.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: spacing.lg),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
