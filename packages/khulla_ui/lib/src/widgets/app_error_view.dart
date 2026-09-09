import 'package:khulla_ui/khulla_ui.dart';

/// A failed read, with an optional retry action.
///
/// Takes a ready-made [message] rather than an exception: the design system
/// has no opinion on error types or localization, so the caller resolves both
/// and this only lays them out.
class AppErrorView extends StatelessWidget {
  /// Builds the error view.
  const AppErrorView({
    required this.message,
    this.retryLabel,
    this.onRetry,
    this.variant = AppFeedbackVariant.centered,
    this.padding,
    super.key,
  });

  /// Ready-made, user-facing failure copy.
  final String message;

  /// Label for the retry button. The button only appears when both this and
  /// [onRetry] are set.
  final String? retryLabel;

  /// Called when the retry button is tapped.
  final VoidCallback? onRetry;

  /// Layout: centered with an icon, or a compact inline block.
  final AppFeedbackVariant variant;

  /// Overrides the variant's default padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isCentered = variant.isCentered;
    final label = retryLabel;
    final retry = onRetry;

    return wrapFeedbackVariant(
      variant: variant,
      child: Padding(
        padding:
            padding ??
            (isCentered
                ? EdgeInsets.symmetric(
                    horizontal: spacing.page,
                    vertical: spacing.xlg,
                  )
                : EdgeInsets.zero),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isCentered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (isCentered) ...[
              AppIcon(
                AppIcons.error,
                size: spacing.xlg,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(height: spacing.md),
            ],
            Text(
              message,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (label != null && retry != null) ...[
              SizedBox(height: isCentered ? spacing.md : spacing.sm),
              AppButton(
                variant: AppButtonVariant.outline,
                size: isCentered ? AppButtonSize.medium : AppButtonSize.small,
                onPressed: retry,
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
