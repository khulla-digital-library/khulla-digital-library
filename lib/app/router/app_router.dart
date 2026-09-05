import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/app/shell/app_shell.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/router/go_router_refresh_stream.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/author/presentation/author_detail_page.dart';
import 'package:khulla/features/catalog/author/presentation/author_list_page.dart';
import 'package:khulla/features/catalog/catalog/presentation/catalog_page.dart';
import 'package:khulla/features/catalog/copy/presentation/copy_list_page.dart';
import 'package:khulla/features/catalog/copy/presentation/label_print_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_detail_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_list_page.dart';
import 'package:khulla/features/circulation/check_out/presentation/check_out_page.dart';
import 'package:khulla/features/circulation/circulation/presentation/circulation_page.dart';
import 'package:khulla/features/circulation/fine/presentation/fine_list_page.dart';
import 'package:khulla/features/circulation/reservation/presentation/reservation_list_page.dart';
import 'package:khulla/features/circulation/return_copy/presentation/return_page.dart';
import 'package:khulla/features/dashboard/presentation/dashboard_page.dart';
import 'package:khulla/features/members/presentation/pages/member_detail_page.dart';
import 'package:khulla/features/members/presentation/pages/member_list_page.dart';
import 'package:khulla/features/opac/presentation/opac_page.dart';
import 'package:khulla/features/reports/presentation/reports_page.dart';
import 'package:khulla/features/settings/presentation/pages/appearance_page.dart';
import 'package:khulla/features/settings/presentation/pages/backup_page.dart';
import 'package:khulla/features/settings/presentation/pages/library_profile_page.dart';
import 'package:khulla/features/settings/presentation/pages/loan_rules_page.dart';
import 'package:khulla/features/settings/presentation/pages/settings_page.dart';
import 'package:khulla/features/settings/presentation/pages/sync_page.dart';
import 'package:khulla/features/staff_auth/presentation/auth/cubit/auth_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/auth/cubit/auth_state.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/onboarding_page.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/cubit/sign_in_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/sign_in_page.dart';
import 'package:khulla/features/users/presentation/pages/role_list_page.dart';
import 'package:khulla/features/users/presentation/pages/user_list_page.dart';
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
/// Two routes sit outside the shell — onboarding and sign-in — and
/// [_redirect] is what decides when the operator is on one of them. It reads
/// [AuthCubit], and `refreshListenable` re-runs it whenever that cubit emits,
/// so signing in or out moves the app on its own with no `context.go` at the
/// call site.
@lazySingleton
class AppRouter {
  AppRouter(this._config, this._auth) {
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: Routes.dashboard,
      refreshListenable: GoRouterRefreshStream(_auth.stream),
      redirect: _redirect,
      routes: [
        GoRoute(
          path: Routes.onboarding,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, _) => BlocProvider<OnboardingCubit>(
            create: (_) => getIt<OnboardingCubit>(),
            child: const OnboardingPage(),
          ),
        ),
        GoRoute(
          path: Routes.signIn,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, _) => BlocProvider<SignInCubit>(
            create: (_) => getIt<SignInCubit>(),
            child: const SignInPage(),
          ),
        ),
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
                        GoRoute(
                          path: Routes.idSegment,
                          builder: (context, state) => TitleDetailPage(
                            titleId: state.pathParameters['id'] ?? '',
                          ),
                        ),
                      ],
                    ),
                    GoRoute(
                      path: Routes.copiesSegment,
                      builder: (context, _) => const CopyListPage(),
                    ),
                    GoRoute(
                      path: Routes.labelsSegment,
                      builder: (context, _) => const LabelPrintPage(),
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
                      path: Routes.idSegment,
                      builder: (context, state) => MemberDetailPage(
                        memberId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.opac,
                  builder: (context, _) => const OpacPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.reports,
                  builder: (context, _) => const ReportsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.users,
                  builder: (context, _) => const UserListPage(),
                  routes: [
                    GoRoute(
                      path: Routes.rolesSegment,
                      builder: (context, _) => const RoleListPage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.settings,
                  builder: (context, _) =>
                      SettingsPage(showDesignSystem: !_config.isProduction),
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
                    GoRoute(
                      path: Routes.syncSegment,
                      builder: (context, _) => const SyncPage(),
                    ),
                    // The component gallery is a development surface: the
                    // release build never declares the route, so there is no
                    // way to reach it by typing the URL either.
                    if (!_config.isProduction)
                      GoRoute(
                        path: Routes.designSystemSegment,
                        builder: (context, _) => const AppDesignGallery(),
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
  final AuthCubit _auth;
  final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  /// The configured router, handed to `MaterialApp.router`.
  late final GoRouter router;

  /// Sends the operator to the one screen their session allows.
  ///
  /// `bootstrap` resolves the session before the first frame, so
  /// [AuthStatus.unknown] here means the catalogue could not be read at all.
  /// It redirects nowhere in that case: guessing "needs setup" would offer to
  /// create a second administrator over the top of a real library, and the
  /// startup failure screen is already what the operator is looking at.
  String? _redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;

    return switch (_auth.state.status) {
      AuthStatus.unknown => null,
      AuthStatus.needsSetup =>
        location == Routes.onboarding ? null : Routes.onboarding,
      AuthStatus.signedOut => location == Routes.signIn ? null : Routes.signIn,
      AuthStatus.signedIn =>
        Routes.isAuthLocation(location) ? Routes.dashboard : null,
    };
  }
}
