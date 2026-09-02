import 'package:go_router/go_router.dart';
import 'package:khulla/app/shell/widgets/shell_brand_mark.dart';
import 'package:khulla/app/shell/widgets/shell_destinations.dart';
import 'package:khulla/app/shell/widgets/shell_theme_toggle.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The app's only shell, adapting its navigation to the window it is given.
///
/// Khulla runs on a maximised desktop window and in a phone browser tab from
/// the same build, so navigation is chosen at layout time rather than at
/// compile time: a rail from [FormFactor.medium] up, a bottom bar below it.
/// Both are driven by the same [shellDestinations] list, so resizing across
/// the breakpoint never reorders or drops a section.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  /// Branch state owned by the router. Each destination is one branch, so a
  /// section keeps its scroll position and navigation stack while the user is
  /// away in another.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) => navigationShell.goBranch(
    index,
    // Tapping the active destination returns to the top of that branch, the
    // behaviour every tabbed app has trained people to expect.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final formFactor = context.formFactor;
    final destinations = shellDestinations(context.l10n);

    if (!formFactor.usesNavigationRail) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.appName),
          actions: const [ShellThemeToggle(), SizedBox(width: 4)],
        ),
        body: navigationShell,
        bottomNavigationBar: AppNavBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: destinations,
        ),
      );
    }

    final extended = formFactor.usesExtendedRail;

    return Scaffold(
      body: Row(
        children: [
          AppNavRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _onDestinationSelected,
            destinations: destinations,
            extended: extended,
            leading: ShellBrandMark(extended: extended),
            trailing: const ShellThemeToggle(),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}
