import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/app/shell/app_shell.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/author/presentation/author_detail_page.dart';
import 'package:khulla/features/catalog/author/presentation/author_list_page.dart';
import 'package:khulla/features/catalog/catalog/presentation/catalog_page.dart';
import 'package:khulla/features/catalog/copy/presentation/copy_list_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_detail_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_form_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_list_page.dart';
import 'package:khulla/features/circulation/check_out/presentation/check_out_page.dart';
import 'package:khulla/features/circulation/circulation/presentation/circulation_page.dart';
import 'package:khulla/features/circulation/fine/presentation/fine_list_page.dart';
import 'package:khulla/features/circulation/reservation/presentation/reservation_list_page.dart';
import 'package:khulla/features/circulation/return_copy/presentation/return_page.dart';
import 'package:khulla/features/dashboard/presentation/dashboard_page.dart';
import 'package:khulla/features/members/presentation/pages/member_detail_page.dart';
import 'package:khulla/features/members/presentation/pages/member_form_page.dart';
import 'package:khulla/features/members/presentation/pages/member_list_page.dart';
import 'package:khulla/features/settings/presentation/pages/appearance_page.dart';
import 'package:khulla/features/settings/presentation/pages/backup_page.dart';
import 'package:khulla/features/settings/presentation/pages/library_profile_page.dart';
import 'package:khulla/features/settings/presentation/pages/loan_rules_page.dart';
import 'package:khulla/features/settings/presentation/pages/settings_page.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Owns the single [GoRouter] instance.
///
/// One [StatefulShellRoute] with one branch per shell destination, in the
/// order `shellDestinations` declares them. The indexed-stack form keeps
/// every branch alive — a section holds its scroll position and navigation
/// stack while the user is away in another — and swaps between them with no
/// transition, which is what a desk tool wants.
///
/// Each branch is a small tree rather than a single page: a list at the
/// branch root, records and editors nested under it. Nesting is what keeps
/// the shell's rail on screen while a librarian moves between records, and
/// what makes the back control on a detail page mean "up to the list".
///
/// Route paths are never written here as strings — [Routes] owns the
/// segments, so a rename is one edit and every caller moves with it.
///
/// There is no redirect guard yet because there is no session to guard on.
/// When staff sign-in lands, add a `refreshListenable` over the auth cubit's
/// stream (see `GoRouterRefreshStream`) and a `redirect` beside it.
@lazySingleton
class AppRouter {
  AppRouter(this._config) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.dashboard,
      debugLogDiagnostics: !_config.isProduction,
      routes: [
        GoRoute(
          path: Routes.root,
          redirect: (_, _) => Routes.dashboard,
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.dashboard,
                  builder: (context, _) => const DashboardPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.catalog,
                  builder: (context, _) => const CatalogPage(),
                  routes: [
                    GoRoute(
                      path: Routes.titlesSegment,
                      builder: (context, _) => const TitleListPage(),
                      routes: [
                        // Declared before `:id` so /titles/new opens the
                        // editor rather than a record with the id "new".
                        GoRoute(
                          path: Routes.newSegment,
                          builder: (context, _) => const TitleFormPage(),
                        ),
                        GoRoute(
                          path: Routes.idSegment,
                          builder: (context, state) => TitleDetailPage(
                            titleId: state.pathParameters['id'] ?? '',
                          ),
                          routes: [
                            GoRoute(
                              path: Routes.editSegment,
                              builder: (context, state) => TitleFormPage(
                                titleId: state.pathParameters['id'],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    GoRoute(
                      path: Routes.copiesSegment,
                      builder: (context, _) => const CopyListPage(),
                    ),
                    GoRoute(
                      path: Routes.authorsSegment,
                      builder: (context, _) => const AuthorListPage(),
                      routes: [
                        GoRoute(
                          path: Routes.idSegment,
                          builder: (context, state) => AuthorDetailPage(
                            authorId: state.pathParameters['id'] ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.circulation,
                  builder: (context, _) => const CirculationPage(),
                  routes: [
                    GoRoute(
                      path: Routes.checkOutSegment,
                      builder: (context, _) => const CheckOutPage(),
                    ),
                    GoRoute(
                      path: Routes.returnsSegment,
                      builder: (context, _) => const ReturnPage(),
                    ),
                    GoRoute(
                      path: Routes.reservationsSegment,
                      builder: (context, _) => const ReservationListPage(),
                    ),
                    GoRoute(
                      path: Routes.finesSegment,
                      builder: (context, _) => const FineListPage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.members,
                  builder: (context, _) => const MemberListPage(),
                  routes: [
                    GoRoute(
                      path: Routes.newSegment,
                      builder: (context, _) => const MemberFormPage(),
                    ),
                    GoRoute(
                      path: Routes.idSegment,
                      builder: (context, state) => MemberDetailPage(
                        memberId: state.pathParameters['id'] ?? '',
                      ),
                      routes: [
                        GoRoute(
                          path: Routes.editSegment,
                          builder: (context, state) => MemberFormPage(
                            memberId: state.pathParameters['id'],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.settings,
                  builder: (context, _) => const SettingsPage(),
                  routes: [
                    GoRoute(
                      path: Routes.librarySegment,
                      builder: (context, _) => const LibraryProfilePage(),
                    ),
                    GoRoute(
                      path: Routes.loanRulesSegment,
                      builder: (context, _) => const LoanRulesPage(),
                    ),
                    GoRoute(
                      path: Routes.appearanceSegment,
                      builder: (context, _) => const AppearancePage(),
                    ),
                    GoRoute(
                      path: Routes.backupSegment,
                      builder: (context, _) => const BackupPage(),
                    ),
                  ],
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
