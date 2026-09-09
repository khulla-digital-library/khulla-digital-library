// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla_ui/khulla_ui.dart';

/// One destination row inside an [AppNavRail], plus its children when the
/// rail is extended.
class AppRailItem extends StatelessWidget {
  const AppRailItem({
    required this.destination,
    required this.extended,
    required this.selected,
    required this.expanded,
    required this.onTap,
    required this.onToggle,
    super.key,
  });

  final AppNavDestination destination;
  final bool extended;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final radius = BorderRadius.circular(context.appRadius.control);

    final foreground = selected ? colors.brand : colors.ink400;
    final glyph = IconTheme.merge(
      data: IconThemeData(color: foreground, size: metrics.iconNav),
      child: destination.icon,
    );

    final row = AppRailRowSurface(
      selected: selected,
      radius: radius,
      onTap: onTap,
      child: SizedBox(
        height: metrics.navRowHeight,
        child: extended
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: metrics.iconNav,
                      child: Center(child: glyph),
                    ),
                    SizedBox(width: spacing.navIconGap),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTextStyles.bodyLarge.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                    if (destination.badge case final count?) ...[
                      SizedBox(width: spacing.xs),
                      AppRailBadge(label: count, selected: selected),
                    ],
                    if (onToggle != null) ...[
                      SizedBox(width: spacing.xxs),
                      AnimatedRotation(
                        duration: context.appMotion.overlay,
                        turns: expanded ? 0 : -0.25,
                        child: AppIcon(
                          AppIcons.chevronDown,
                          size: metrics.icon,
                          color: foreground,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : Center(child: glyph),
      ),
    );

    final item = extended
        ? row
        : Tooltip(
            message: destination.label,
            preferBelow: false,
            child: row,
          );

    final children = destination.children;
    final showChildren = extended && expanded && children.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          item,
          if (showChildren)
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, child) in children.indexed)
                    AppRailChildRow(
                      child: child,
                      isLast: index == children.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// One sub-section row under an expanded [AppRailItem].
class AppRailChildRow extends StatelessWidget {
  const AppRailChildRow({
    required this.child,
    required this.isLast,
    super.key,
  });

  final AppNavChild child;

  /// Whether to draw the connector line below the bullet. The last child has
  /// nothing under it to connect to.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final radius = BorderRadius.circular(context.appRadius.container);
    final metrics = context.appMetrics;
    final active = child.selected;
    final foreground = active ? colors.brand : colors.ink300;

    // Line the sub-item's label up with its parent's, so the rail reads as
    // one text column rather than two: the parent's inset, its glyph and the
    // icon gap, less what the bullet and its own gap already take.
    final indent =
        spacing.sm +
        metrics.iconNav +
        spacing.navIconGap -
        metrics.iconDense -
        spacing.xs;

    return AppRipple(
      onTap: child.onSelected,
      borderRadius: radius,
      pressScale: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? colors.tints.navRow : Colors.transparent,
          borderRadius: radius,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: spacing.sm),
          child: IntrinsicHeight(
            child: Row(
              children: [
                AppRailChildBullet(active: active, isLast: isLast),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.xs + 2),
                    child: Text(
                      child.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTextStyles.body.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
                if (child.badge case final count?)
                  Text(
                    count,
                    style: context.appTextStyles.micro.copyWith(
                      color: colors.ink500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bullet before a sub-item, and the hairline that joins it to the next.
///
/// A filled dot ringed in the surface color rather than an outline circle:
/// at 6px an outlined dot is a smudge, and the ring is what lets the
/// connector line pass behind it cleanly.
class AppRailChildBullet extends StatelessWidget {
  const AppRailChildBullet({
    required this.active,
    required this.isLast,
    super.key,
  });

  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: context.appMetrics.iconDense,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? colors.brand : colors.ink600,
            ),
          ),
          Expanded(
            child: isLast
                ? const SizedBox.shrink()
                : Container(width: 1, color: colors.hairlineStrong),
          ),
        ],
      ),
    );
  }
}
