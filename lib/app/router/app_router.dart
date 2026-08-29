import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/app/shell/app_shell.dart';
import 'package:khulla/app/shell/widgets/animated_branch_container.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/widgets/feature_placeholder_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Owns the single [GoRouter] instance.
///
/// One [StatefulShellRoute] with one branch per shell destination, in the
/// order `shellDestinations` declares them.
///
/// Every branch renders [FeaturePlaceholderView] today. Building a section
/// means adding `features/<name>/` and swapping its placeholder for that
/// feature's page here — nothing else in the shell changes.
///
/// There is no redirect guard yet because there is no session to guard on.
/// When staff sign-in lands, add a `refreshListenable` over the auth cubit's
/// stream (see `GoRouterRefreshStream`) and a `redirect` beside it.
@lazySingleton
class AppRouter {
  AppRouter(this._config) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.catalog,
      debugLogDiagnostics: !_config.isProduction,
      routes: [
        GoRoute(
          path: Routes.root,
          redirect: (_, _) => Routes.catalog,
        ),
        StatefulShellRoute(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          navigatorContainerBuilder: (context, navigationShell, children) =>
              AnimatedBranchContainer(
                currentIndex: navigationShell.currentIndex,
                children: children,
              ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.catalog,
                  builder: (context, _) => FeaturePlaceholderView(
                    section: context.l10n.navCatalog,
                    icon: Icons.menu_book_rounded,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.circulation,
                  builder: (context, _) => FeaturePlaceholderView(
                    section: context.l10n.navCirculation,
                    icon: Icons.swap_horiz_rounded,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.members,
                  builder: (context, _) => FeaturePlaceholderView(
                    section: context.l10n.navMembers,
                    icon: Icons.people_rounded,
                  ),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.settings,
                  builder: (context, _) => FeaturePlaceholderView(
                    section: context.l10n.navSettings,
                    icon: Icons.settings_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  final AppConfig _config;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  /// The configured router, handed to `MaterialApp.router`.
  late final GoRouter router;
}
