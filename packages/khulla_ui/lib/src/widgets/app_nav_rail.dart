import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_nav_rail}
/// Side navigation for wide windows, the counterpart to [AppNavBar].
///
/// Built on Material's [NavigationRail] so keyboard traversal, semantics, and
/// the app's [NavigationRailThemeData] all apply for free. Collapsed it shows
/// icons with labels beneath; [extended] shows a single labelled column, which
/// only fits from [FormFactor.large] up.
/// {@endtemplate}
class AppNavRail extends StatelessWidget {
  /// {@macro app_nav_rail}
  const AppNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.leading,
    this.trailing,
    super.key,
  }) : assert(destinations.length >= 2, 'Need at least 2 destinations');

  /// Index of the active destination.
  final int selectedIndex;

  /// Called with the index of the destination the user picked.
  final ValueChanged<int> onDestinationSelected;

  /// Destinations, in display order. Shared with [AppNavBar].
  final List<AppNavDestination> destinations;

  /// Whether labels sit beside icons in one wide column.
  final bool extended;

  /// Pinned above the destinations — typically the product mark.
  final Widget? leading;

  /// Pinned to the bottom of the rail — typically account or settings.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final bottomSlot = trailing;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: NavigationRail(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        extended: extended,
        // NavigationRail asserts that an extended rail carries no label type.
        labelType: extended ? null : NavigationRailLabelType.all,
        minWidth: spacing.xxlg + spacing.lg, // 72
        minExtendedWidth: 220,
        leading: leading == null
            ? null
            : Padding(
                padding: EdgeInsets.only(top: spacing.sm, bottom: spacing.xs),
                child: leading,
              ),
        // Expanded inside the rail's column pushes the slot to the bottom
        // edge instead of letting it float under the last destination.
        trailing: bottomSlot == null
            ? null
            : Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: spacing.md),
                    child: bottomSlot,
                  ),
                ),
              ),
        destinations: [
          for (final destination in destinations)
            NavigationRailDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}
