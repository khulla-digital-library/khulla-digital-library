import 'package:khulla_ui/khulla_ui.dart';

/// A collection that came back with nothing, with an optional first action.
///
/// Takes ready-made copy rather than a domain type: the design system has no
/// opinion on what was empty or on localization, so the caller resolves both
/// and this only lays them out.
class AppEmptyView extends StatelessWidget {
  /// Builds the empty-state view.
  const AppEmptyView({
    required this.title,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.variant = AppFeedbackVariant.centered,
    this.padding,
    super.key,
  });

  /// Short heading, e.g. "No titles yet".
  final String title;

  /// Supporting copy shown below [title].
  final String message;

  /// Drawn bare above the copy, muted. Omitted in
  /// [AppFeedbackVariant.inline], which has no room for it.
  final IconData? icon;

  /// Label for the action button. The button only appears when both this and
  /// [onAction] are set.
  final String? actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  /// Layout: centered with an icon badge, or a compact inline block.
  final AppFeedbackVariant variant;

  /// Overrides the variant's default padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isCentered = variant.isCentered;
    final glyph = icon;
    final label = actionLabel;
    final action = onAction;

    return Padding(
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
          if (isCentered && glyph != null) ...[
            Icon(glyph, size: spacing.lg, color: context.appColors.textMuted),
            SizedBox(height: spacing.sm),
          ],
          Text(
            title,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: scheme.onSurface,
            ),
          ),
          SizedBox(height: spacing.xxs),
          Text(
            message,
            textAlign: isCentered ? TextAlign.center : TextAlign.start,
            style: context.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (label != null && action != null) ...[
            SizedBox(height: isCentered ? spacing.md : spacing.sm),
            AppButton(
              size: isCentered ? AppButtonSize.medium : AppButtonSize.small,
              onPressed: action,
              child: Text(label),
            ),
          ],
        ],
      ),
    );
  }
}
