import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/app/shell/widgets/shell_account_chip.dart';
import 'package:khulla/app/shell/widgets/shell_brand_mark.dart';
import 'package:khulla/app/shell/widgets/shell_destinations.dart';
import 'package:khulla/app/shell/widgets/shell_footer_card.dart';
import 'package:khulla/app/shell/widgets/shell_more_sheet.dart';
import 'package:khulla/app/shell/widgets/shell_notifications_button.dart';
import 'package:khulla/app/shell/widgets/shell_page_title.dart';
import 'package:khulla/app/shell/widgets/shell_theme_toggle.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The app's only shell, adapting its navigation to the window it is given.
///
/// Khulla runs on a maximised desktop window and in a phone browser tab from
/// the same build, so navigation is chosen at layout time rather than at
/// compile time: a rail from [FormFactor.medium] up, a bottom bar below it.
/// Both are driven by the same [shellDestinations] list, so resizing across
/// the breakpoint never reorders or drops a section.
///
/// The shell owns the top bar, and the top bar sits *outside* the page's
/// scroll view. That is the whole reason it lives here: the page title, the
/// global search and the account control have to stay put while a catalogue
/// of ten thousand titles scrolls, and no arrangement inside a page achieves
/// that as simply.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  /// Branch state owned by the router. Each destination is one branch, so a
  /// section keeps its scroll position and navigation stack while the user is
  /// away in another.
  final StatefulNavigationShell navigationShell;

  /// How many sections the compact bottom bar shows before *More*.
  static const int _compactSlots = 4;

  void _goBranch(int index) => navigationShell.goBranch(
    index,
    // Tapping the active destination returns to the top of that branch, the
    // behaviour every tabbed app has trained people to expect.
    initialLocation: index == navigationShell.currentIndex,
  );

  void _goRoute(BuildContext context, String route) => context.go(route);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formFactor = context.formFactor;
    final destinations = shellDestinations(l10n);
    final location = GoRouterState.of(context).uri.path;

    final page = shellPageTitle(
      context,
      location,
      l10n,
      onNavigate: (route) => _goRoute(context, route),
    );

    final topBar = AppTopBar(
      title: page.title,
      breadcrumbs: page.crumbs.isEmpty
          ? null
          : AppBreadcrumbs(crumbs: page.crumbs),
      search: AppSearchField(
        hintText: l10n.shellSearchHint,
        clearTooltip: l10n.commonClearSearch,
        dense: true,
        onChanged: (_) {},
        onSubmitted: (_) => showNotWiredToast(context),
      ),
      actions: const [ShellNotificationsButton(), ShellThemeToggle()],
      trailing: ShellAccountChip(compact: formFactor.isCompact),
      leading: formFactor.usesNavigationRail
          ? null
          : AppIconButton(
              icon: Icons.grid_view_rounded,
              tooltip: l10n.shellMoreTitle,
              onPressed: () => unawaited(
                showShellMoreSheet(
                  context,
                  destinations: destinations,
                  current: location,
                ),
              ),
            ),
    );

    if (!formFactor.usesNavigationRail) {
      final compact = destinations.where((d) => d.primary).toList();
      final index = navigationShell.currentIndex;

      return Scaffold(
        body: Column(
          children: [
            topBar,
            Expanded(child: navigationShell),
          ],
        ),
        bottomNavigationBar: AppNavBar(
          selectedIndex: index < _compactSlots ? index : _compactSlots,
          onDestinationSelected: (selected) {
            if (selected < _compactSlots) {
              _goBranch(selected);
              return;
            }
            unawaited(
              showShellMoreSheet(
                context,
                destinations: destinations,
                current: location,
              ),
            );
          },
          destinations: [
            for (final destination in compact)
              AppNavDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
            AppNavDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: l10n.navMore,
            ),
          ],
        ),
      );
    }

    final extended = formFactor.usesExtendedRail;

    return Scaffold(
      body: Row(
        children: [
          AppNavRail(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            extended: extended,
            leading: ShellBrandMark(extended: extended),
            trailing: extended ? null : const ShellThemeToggle(),
            footer: extended ? const ShellFooterCard() : null,
            destinations: [
              for (final destination in destinations)
                AppNavDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                  children: [
                    for (final child in destination.children)
                      AppNavChild(
                        label: child.label,
                        selected: Routes.isUnder(location, child.route),
                        onSelected: () => _goRoute(context, child.route),
                      ),
                  ],
                ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                topBar,
                Expanded(child: navigationShell),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
