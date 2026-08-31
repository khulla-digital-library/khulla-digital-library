import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_nav_bar}
/// Bottom navigation for narrow windows, the counterpart to [AppNavRail].
///
/// Built on Material's [NavigationBar] so keyboard traversal, semantics, and
/// the app's [NavigationBarThemeData] all apply for free — the same
/// arrangement [AppNavRail] has with [NavigationRail].
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
    final scheme = context.colorScheme;

    return DecoratedBox(
      // Mirrors the rail's trailing edge, so the chrome reads the same either
      // side of the breakpoint.
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: [
          for (final destination in destinations)
            NavigationDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: destination.label,
            ),
        ],
      ),
    );
  }
}
