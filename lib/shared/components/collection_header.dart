import 'package:khulla_ui/khulla_ui.dart';

/// The block at the top of a collection screen: what the list is, how big it
/// is, and the one thing the screen is for.
///
/// One primary action, per the page recipe — everything else goes in
/// [menuActions] behind an [AppMenuButton] rather than becoming a second
/// button of equal weight. On a compact window the action drops below the
/// title and stretches, because a 100px button beside a wrapped heading is
/// the worst of both.
class CollectionHeader extends StatelessWidget {
  const CollectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.menuActions = const [],
    this.menuTooltip,
    this.leading,
    super.key,
  });

  /// The collection's name.
  final String title;

  /// A count or a line of context under it.
  final String subtitle;

  /// The primary action's label. Null renders no button.
  final String? actionLabel;

  /// Runs the primary action.
  final VoidCallback? onAction;

  /// Secondary actions, shown behind an overflow menu.
  final List<AppMenuAction> menuActions;

  /// Tooltip for the overflow control, required whenever [menuActions] is
  /// not empty.
  final String? menuTooltip;

  /// A back control or breadcrumb shown above the title on a nested screen.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final label = actionLabel;
    final tooltip = menuTooltip;

    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            color: context.appColors.textHigh,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          subtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );

    final actions = <Widget>[
      if (menuActions.isNotEmpty && tooltip != null)
        AppMenuButton(actions: menuActions, tooltip: tooltip),
      if (label != null)
        AppButton(
          size: AppButtonSize.medium,
          onPressed: onAction,
          child: Text(label),
        ),
    ];

    final lead = leading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lead != null) ...[lead, SizedBox(height: spacing.sm)],
        if (context.formFactor.isCompact) ...[
          heading,
          if (actions.isNotEmpty) ...[
            SizedBox(height: spacing.md),
            Row(
              children: [
                for (final (index, action) in actions.indexed) ...[
                  if (index > 0) SizedBox(width: spacing.xs),
                  if (action is AppButton) Expanded(child: action) else action,
                ],
              ],
            ),
          ],
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: heading),
              SizedBox(width: spacing.lg),
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (index, action) in actions.indexed) ...[
                      if (index > 0) SizedBox(width: spacing.xs),
                      action,
                    ],
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
