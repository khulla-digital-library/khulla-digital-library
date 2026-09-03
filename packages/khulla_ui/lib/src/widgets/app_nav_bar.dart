import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_nav_bar}
/// Bottom navigation for narrow windows, the counterpart to [AppNavRail].
///
/// A **floating bordered bar inset from the edges**, not an edge-to-edge
/// Material bottom bar with a pill indicator. It reads as a control sitting
/// on the page rather than as a slab bolted to the bottom of the screen,
/// which is what keeps a phone window looking like the same product as the
/// 1600px one.
///
/// Selection is carried by color alone — brand glyph and brand label against
/// the resting ink. At four destinations there is no room for an indicator
/// that does not crowd the labels.
/// {@endtemplate}
class AppNavBar extends StatelessWidget {
  /// {@macro app_nav_bar}
  const AppNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  }) : assert(destinations.length >= 2, 'Need at least 2 destinations');

  /// Index of the active destination.
  final int selectedIndex;

  /// Called with the index of the destination the user picked.
  final ValueChanged<int> onDestinationSelected;

  /// Destinations, in display order. Shared with [AppNavRail].
  final List<AppNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          spacing.sm,
          spacing.xs,
          spacing.sm,
          spacing.xs,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(context.appRadius.container),
            border: Border.all(color: colors.hairline),
            boxShadow: context.appShadows.card,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.sm),
            child: Row(
              children: [
                for (final (index, destination) in destinations.indexed)
                  Expanded(
                    child: _NavBarItem(
                      destination: destination,
                      selected: index == selectedIndex,
                      onTap: () => onDestinationSelected(index),
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

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final foreground = selected ? colors.brand : colors.ink400;

    return AppRipple(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.appRadius.container),
      pressScale: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(
            data: IconThemeData(
              color: foreground,
              size: context.appMetrics.iconLarge,
            ),
            child: destination.icon,
          ),
          SizedBox(height: context.appSpacing.xxs),
          Text(
            destination.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTextStyles.label.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
