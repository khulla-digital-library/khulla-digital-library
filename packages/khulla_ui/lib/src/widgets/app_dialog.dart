import 'package:khulla_ui/khulla_ui.dart';

/// How wide a dialog is allowed to get.
///
/// A dialog is sized by the shape of its content, not by the screen. A
/// confirmation is [md]; a form is [xl], which is the width most of the
/// product's dialogs use.
enum AppDialogWidth {
  /// 384px — a single short question.
  sm(384),

  /// 448px — the confirmation default.
  md(448),

  /// 512px — a short form.
  lg(512),

  /// 576px — the canonical form dialog.
  xl(576),

  /// 672px — a two-column form.
  xxl(672),

  /// 768px — a form with a table or a preview in it.
  xxxl(768);

  AppDialogWidth(this.value);

  /// The cap, in logical pixels.
  final double value;
}

/// {@template app_dialog}
/// The system's modal chrome.
///
/// Three details carry the product's character and are the reason a screen
/// must never hand-roll a `Dialog`:
///
/// * the **close chip floats outside the top-right corner**, shifts a little
///   further out on hover and rotates its glyph 90° — this is the single most
///   recognisable interaction in the design language;
/// * the body scrolls **inside** the dialog at a 90% viewport-height cap, so
///   a long form never pushes the footer off screen;
/// * the footer is a right-aligned row on a wide window and a **reversed
///   column** on a narrow one, which keeps the confirming action under the
///   thumb on a phone.
///
/// Use [AppDialog.show] for arbitrary content and [AppDialog.confirmDestructive]
/// for the "delete this?" prompt.
/// {@endtemplate}
class AppDialog extends StatelessWidget {
  /// {@macro app_dialog}
  const AppDialog({
    required this.title,
    required this.actions,
    this.message,
    this.content,
    this.width = AppDialogWidth.md,
    this.icon,
    this.iconWidget,
    this.iconTone = AppStatusTone.danger,
    this.showClose = true,
    super.key,
  });

  /// The dialog's heading, already localized.
  final String title;

  /// The supporting line under the heading.
  final String? message;

  /// Arbitrary body content between the message and the actions.
  final Widget? content;

  /// The button row. Compose it with [AppDialog.primaryAction] and friends.
  final Widget actions;

  /// The width cap.
  final AppDialogWidth width;

  /// A glyph in a tinted circular badge above the title.
  final AppIconSpec? icon;

  /// A custom badge glyph, taking precedence over [icon].
  final Widget? iconWidget;

  /// Which wash and ink the badge uses.
  final AppStatusTone iconTone;

  /// Whether to draw the close chip. Hide it for a step the operator must
  /// answer rather than dismiss.
  final bool showClose;

  /// Presents an [AppDialog] and resolves to whatever it is popped with.
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required WidgetBuilder actionsBuilder,
    String? message,
    Widget? content,
    AppDialogWidth width = AppDialogWidth.md,
    AppIconSpec? icon,
    Widget? iconWidget,
    AppStatusTone iconTone = AppStatusTone.danger,
    bool barrierDismissible = true,
    bool showClose = true,
  }) => showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => AppDialog(
      title: title,
      message: message,
      content: content,
      width: width,
      icon: iconWidget == null ? icon : null,
      iconWidget: iconWidget,
      iconTone: iconTone,
      showClose: showClose,
      actions: Builder(builder: actionsBuilder),
    ),
  );

  /// Confirms a destructive action. Resolves true only on confirm.
  static Future<bool> confirmDestructive({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    AppIconSpec? icon = AppIcons.delete,
    Widget? iconWidget,
  }) async {
    final confirmed = await show<bool>(
      context: context,
      title: title,
      message: message,
      icon: iconWidget == null ? icon : null,
      iconWidget: iconWidget,
      actionsBuilder: (dialogContext) => AppDialogActions(
        children: [
          secondaryAction(
            context: dialogContext,
            label: cancelLabel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
          destructiveAction(
            context: dialogContext,
            label: confirmLabel,
            onPressed: () => Navigator.of(dialogContext).pop(true),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// The confirming action of a destructive prompt.
  ///
  /// Outlined rather than filled: a solid red slab reads as the recommended
  /// choice, and in a "delete this?" prompt it is not.
  static Widget destructiveAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) => AppButton(
    onPressed: onPressed,
    variant: AppButtonVariant.destructive,
    child: Text(label),
  );

  /// The confirming action of a non-destructive prompt.
  static Widget primaryAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) => AppButton(
    onPressed: onPressed,
    isLoading: isLoading,
    child: Text(label),
  );

  /// The dismissing action. Always sits left of the confirming one.
  static Widget secondaryAction({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
  }) => AppButton(
    onPressed: onPressed,
    variant: AppButtonVariant.outline,
    child: Text(label),
  );

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    final badgeGlyph =
        iconWidget ??
        (icon == null
            ? null
            : AppIcon(
                icon!,
                color: iconTone.foreground(context),
                size: context.appMetrics.iconLarge,
              ));

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (badgeGlyph != null) ...[
          Center(
            child: Container(
              width: spacing.xxlg,
              height: spacing.xxlg,
              decoration: BoxDecoration(
                color: iconTone.background(context),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: badgeGlyph,
            ),
          ),
          SizedBox(height: spacing.md),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: typography.formTitle.copyWith(color: colors.ink200),
        ),
        if (message != null) ...[
          SizedBox(height: spacing.xs),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(color: colors.mutedForeground),
          ),
        ],
        if (content != null) ...[SizedBox(height: spacing.md), content!],
        SizedBox(height: spacing.lg),
        actions,
      ],
    );

    return AppDialogShell(
      maxWidth: width.value,
      showClose: showClose,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.dialog),
        child: body,
      ),
    );
  }
}

/// A dialog's button row: right-aligned on a wide window, reversed column on
/// a narrow one so the confirming action lands under the thumb.
///
/// Pass the children in reading order — dismiss first, confirm last.
class AppDialogActions extends StatelessWidget {
  const AppDialogActions({required this.children, super.key});

  /// The buttons, dismiss-first.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final narrow = context.formFactor.isCompact;

    if (narrow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children.reversed) ...[
            child,
            if (child != children.first) SizedBox(height: spacing.xs),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final child in children) ...[
          if (child != children.first) SizedBox(width: spacing.xs),
          child,
        ],
      ],
    );
  }
}
