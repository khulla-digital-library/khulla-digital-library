import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_section_header}
/// Title, optional supporting line, and one trailing action for a section of
/// a page or the top of a card.
///
/// One action, not a row of equals: a section that needs more puts the rest
/// behind [AppMenuButton]. Takes ready-made strings — the design system does
/// not know what the section is or which locale it is in.
/// {@endtemplate}
class AppSectionHeader extends StatelessWidget {
  /// {@macro app_section_header}
  const AppSectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    this.icon,
    this.dense = false,
    super.key,
  });

  /// Section heading.
  final String title;

  /// Secondary line under [title] — a count, a date range, a hint.
  final String? subtitle;

  /// The section's single action, typically an [AppButton] or
  /// [AppIconButton].
  final Widget? trailing;

  /// Glyph shown before [title] in a tinted square.
  final IconData? icon;

  /// Uses the card heading ramp rather than the section one. Set inside a
  /// card, where the page-level size is too loud.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final textTheme = context.textTheme;
    final glyph = icon;
    final caption = subtitle;

    return Row(
      children: [
        if (glyph != null) ...[
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(context.appRadius.tile),
            ),
            child: Padding(
              padding: EdgeInsets.all(spacing.xs),
              child: Icon(glyph, size: spacing.md + 2, color: scheme.primary),
            ),
          ),
          SizedBox(width: spacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (dense ? textTheme.titleSmall : textTheme.titleMedium)
                    ?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.2,
                      color: scheme.onSurface,
                    ),
              ),
              if (caption != null) ...[
                SizedBox(height: spacing.xxs),
                Text(
                  caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: spacing.sm), trailing!],
      ],
    );
  }
}
