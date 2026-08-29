import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Centered failure copy with an optional retry action.
///
/// Renders [AppException] through [AppExceptionL10n] so error strings stay in
/// the ARB files rather than coming from the data layer.
class ErrorRetryView extends StatelessWidget {
  const ErrorRetryView({super.key, this.error, this.onRetry});

  final AppException? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final retry = onRetry;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.page,
        vertical: spacing.xlg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: spacing.xlg,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(height: spacing.md),
          Text(
            error?.localizedMessage(l10n) ?? l10n.errorUnknown,
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (retry != null) ...[
            SizedBox(height: spacing.md),
            AppButton(
              variant: AppButtonVariant.outline,
              onPressed: retry,
              child: Text(l10n.commonRetry),
            ),
          ],
        ],
      ),
    );
  }
}
