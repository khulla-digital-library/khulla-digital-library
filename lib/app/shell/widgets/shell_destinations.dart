import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The shell's destinations, in display order.
///
/// This list is the single source of truth for navigation: index `i` here is
/// `StatefulShellBranch` `i` in `AppRouter`, and the same list feeds both
/// [AppNavBar] on a narrow window and [AppNavRail] on a wide one. Adding a
/// section means adding an entry here and a branch there, in the same place.
List<AppNavDestination> shellDestinations(AppLocalizations l10n) => [
  AppNavDestination(
    icon: const Icon(Icons.menu_book_outlined),
    selectedIcon: const Icon(Icons.menu_book_rounded),
    label: l10n.navCatalog,
  ),
  AppNavDestination(
    icon: const Icon(Icons.swap_horiz_outlined),
    selectedIcon: const Icon(Icons.swap_horiz_rounded),
    label: l10n.navCirculation,
  ),
  AppNavDestination(
    icon: const Icon(Icons.people_outline_rounded),
    selectedIcon: const Icon(Icons.people_rounded),
    label: l10n.navMembers,
  ),
  AppNavDestination(
    icon: const Icon(Icons.settings_outlined),
    selectedIcon: const Icon(Icons.settings_rounded),
    label: l10n.navSettings,
  ),
];
