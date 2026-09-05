import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One section of the app, as the shell's navigation describes it.
///
/// This list is the single source of truth for navigation: index `i` here is
/// `StatefulShellBranch` `i` in `AppRouter`, the same list feeds the rail on a
/// window and the bottom bar on a phone, and [children] gives the rail the
/// sub-sections a branch contains without the router being asked twice.
class ShellDestination {
  const ShellDestination({
    required this.label,
    required this.icon,
    required this.route,
    this.children = const [],
    this.expandable = false,
    this.primary = false,
  });

  /// The section's name.
  final String label;

  /// The section's glyph. One glyph serves both states — selection reads
  /// through colour, not through a heavier weight.
  final AppIconSpec icon;

  /// The branch's root route.
  final String route;

  /// The routes nested under it, listed in the extended rail.
  final List<ShellChild> children;

  /// Whether the rail row expands and collapses [children] on tap. When false,
  /// children stay visible whenever the rail is extended.
  final bool expandable;

  /// Whether the section earns a slot in the compact bottom bar, which holds
  /// four before it starts eating labels. Everything else lives behind
  /// *More*.
  final bool primary;
}

/// One route nested under a [ShellDestination].
class ShellChild {
  const ShellChild({required this.label, required this.route});

  /// The sub-section's name.
  final String label;

  /// Where it goes.
  final String route;
}

/// The shell's destinations, in display order.
///
/// The order is a shift's order, not an alphabet: a desk shift starts by
/// looking at what is out and overdue, then works the catalogue and the desk,
/// then the people. Reports, staff and settings are the things you open once
/// a week, so they sit under the daily work rather than above it.
List<ShellDestination> shellDestinations(AppLocalizations l10n) => [
  ShellDestination(
    label: l10n.navDashboard,
    icon: AppIcons.dashboard,
    route: Routes.dashboard,
    primary: true,
  ),
  ShellDestination(
    label: l10n.navCatalog,
    icon: AppIcons.book,
    route: Routes.catalog,
    primary: true,
    expandable: true,
    children: [
      ShellChild(label: l10n.navCatalogTitles, route: Routes.catalogTitles),
      ShellChild(label: l10n.navCatalogCopies, route: Routes.catalogCopies),
      ShellChild(label: l10n.navCatalogAuthors, route: Routes.catalogAuthors),
      ShellChild(label: l10n.navCatalogLabels, route: Routes.catalogLabels),
    ],
  ),
  ShellDestination(
    label: l10n.navCirculation,
    icon: AppIcons.transfer,
    route: Routes.circulation,
    primary: true,
    expandable: true,
    children: [
      ShellChild(
        label: l10n.navCirculationCheckOut,
        route: Routes.circulationCheckOut,
      ),
      ShellChild(
        label: l10n.navCirculationReturn,
        route: Routes.circulationReturn,
      ),
      ShellChild(
        label: l10n.navCirculationReservations,
        route: Routes.circulationReservations,
      ),
      ShellChild(
        label: l10n.navCirculationFines,
        route: Routes.circulationFines,
      ),
    ],
  ),
  ShellDestination(
    label: l10n.navMembers,
    icon: AppIcons.people,
    route: Routes.members,
    primary: true,
  ),
  // ShellDestination(
  //   label: l10n.navOpac,
  //   icon: AppIcons.discover,
  //   route: Routes.opac,
  // ),
  // ShellDestination(
  //   label: l10n.navReports,
  //   icon: AppIcons.insights,
  //   route: Routes.reports,
  // ),
  // ShellDestination(
  //   label: l10n.navUsers,
  //   icon: AppIcons.idCard,
  //   route: Routes.users,
  //   children: [
  //     ShellChild(label: l10n.navUsersAccounts, route: Routes.users),
  //     ShellChild(label: l10n.navUsersRoles, route: Routes.usersRoles),
  //   ],
  // ),
  ShellDestination(
    label: l10n.navSettings,
    icon: AppIcons.settings,
    route: Routes.settings,
    expandable: true,
    children: [
      ShellChild(
        label: l10n.navSettingsLibrary,
        route: Routes.settingsLibrary,
      ),
      ShellChild(
        label: l10n.navSettingsLoanRules,
        route: Routes.settingsLoanRules,
      ),
      ShellChild(
        label: l10n.navSettingsAppearance,
        route: Routes.settingsAppearance,
      ),
      ShellChild(label: l10n.navSettingsBackup, route: Routes.settingsBackup),
      ShellChild(label: l10n.navSettingsSync, route: Routes.settingsSync),
    ],
  ),
];
