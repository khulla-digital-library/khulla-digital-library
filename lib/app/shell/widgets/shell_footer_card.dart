import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The card at the bottom of the extended rail.
///
/// It is the one piece of chrome that says something rather than navigating:
/// this app holds a library's only copy of its records, and the rail is where
/// an operator will actually read a reminder to back them up. It links to the
/// screen that does it, so the reminder is one click from being acted on.
class ShellFooterCard extends StatelessWidget {
  const ShellFooterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(context.appRadius.card),
        border: Border.all(color: colors.hairline),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shield_moon_outlined,
                  size: spacing.md,
                  color: context.colorScheme.primary,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Text(
                    l10n.shellFooterTitle,
                    maxLines: 2,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textHigh,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.xxs),
            Text(
              l10n.shellFooterBody,
              style: context.textTheme.labelSmall?.copyWith(
                color: colors.textMuted,
                height: 1.4,
              ),
            ),
            SizedBox(height: spacing.xs),
            AppButton(
              size: AppButtonSize.small,
              expand: true,
              onPressed: () => context.go(Routes.settingsBackup),
              child: Text(l10n.shellFooterAction),
            ),
          ],
        ),
      ),
    );
  }
}
