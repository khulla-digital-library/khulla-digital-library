import 'package:khulla_ui/khulla_ui.dart';

/// A collection that came back with nothing, with an optional first action.
///
/// Generous on purpose: 96px of vertical padding, a large muted glyph, an
/// 18px bold heading, one line of description and at most one button. An
/// empty table is the screen a new library sees most, and a cramped one reads
/// as an error rather than an invitation.
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
  final AppIconSpec? icon;

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

    return wrapFeedbackVariant(
      variant: variant,
      child: Padding(
        padding:
            padding ??
            (isCentered
                ? EdgeInsets.symmetric(
                    horizontal: spacing.page,
                    vertical: spacing.emptyStateVertical,
                  )
                : EdgeInsets.zero),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: isCentered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            if (isCentered && glyph != null) ...[
              AppIcon(
                glyph,
                size: spacing.xxlg,
                color: context.appColors.hairlineStrong,
              ),
              SizedBox(height: spacing.lg),
            ],
            Text(
              title,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: isCentered
                  ? context.appTextStyles.title.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    )
                  : context.appTextStyles.sectionTitle.copyWith(
                      color: scheme.onSurface,
                    ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              message,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: context.appTextStyles.body.copyWith(
                color: context.appColors.mutedForeground,
              ),
            ),
            if (label != null && action != null) ...[
              SizedBox(height: isCentered ? spacing.lg : spacing.sm),
              AppButton(
                size: isCentered ? AppButtonSize.medium : AppButtonSize.small,
                icon: AppIcons.add,
                onPressed: action,
                child: Text(label),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
