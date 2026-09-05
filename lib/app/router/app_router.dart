import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/app/shell/app_shell.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/router/go_router_refresh_stream.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/copy/presentation/copy_list_page.dart';
import 'package:khulla/features/catalog/copy/presentation/cubit/copy_cubit.dart';
import 'package:khulla/features/catalog/copy/presentation/label_print_page.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title/title_cubit.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title/title_detail_cubit.dart';
import 'package:khulla/features/catalog/title/presentation/title_detail_page.dart';
import 'package:khulla/features/catalog/title/presentation/title_list_page.dart';
import 'package:khulla/features/circulation/check_out/presentation/check_out_page.dart';
import 'package:khulla/features/circulation/check_out/presentation/cubit/check_out_cubit.dart';
import 'package:khulla/features/circulation/fine/presentation/cubit/fine_list_cubit.dart';
import 'package:khulla/features/circulation/fine/presentation/fine_list_page.dart';
import 'package:khulla/features/circulation/reservation/presentation/cubit/reservation_list_cubit.dart';
import 'package:khulla/features/circulation/reservation/presentation/reservation_list_page.dart';
import 'package:khulla/features/circulation/return_copy/presentation/cubit/return_cubit.dart';
import 'package:khulla/features/circulation/return_copy/presentation/return_page.dart';
import 'package:khulla/features/dashboard/presentation/dashboard_page.dart';
import 'package:khulla/features/members/presentation/cubit/member_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_detail_cubit.dart';
import 'package:khulla/features/members/presentation/pages/member_detail_page.dart';
import 'package:khulla/features/members/presentation/pages/member_list_page.dart';
import 'package:khulla/features/settings/presentation/cubit/library_profile_cubit.dart';
import 'package:khulla/features/settings/presentation/cubit/loan_rules_cubit.dart';
import 'package:khulla/features/settings/presentation/pages/appearance_page.dart';
import 'package:khulla/features/settings/presentation/pages/backup_page.dart';
import 'package:khulla/features/settings/presentation/pages/library_profile_page.dart';
import 'package:khulla/features/settings/presentation/pages/loan_rules_page.dart';
import 'package:khulla/features/settings/presentation/pages/sync_page.dart';
import 'package:khulla/features/staff_auth/presentation/auth/cubit/auth_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/auth/cubit/auth_state.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/onboarding_page.dart';
import 'package:khulla/features/staff_auth/presentation/recover_password/cubit/recover_password_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/recover_password/recover_password_page.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/cubit/sign_in_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/sign_in_page.dart';
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
      initialLocation: Routes.catalogTitles,
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
            create: (_) {
              final cubit = getIt<SignInCubit>();
              unawaited(cubit.loadRecoveryAvailability());
              return cubit;
            },
            child: const SignInPage(),
          ),
        ),
        GoRoute(
          path: Routes.recoverPassword,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, _) => BlocProvider<RecoverPasswordCubit>(
            create: (_) => getIt<RecoverPasswordCubit>(),
            child: const RecoverPasswordPage(),
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
                  redirect: (_, state) => state.uri.path == Routes.catalog
                      ? Routes.catalogTitles
                      : null,
                  routes: [
                    GoRoute(
                      path: Routes.titlesSegment,
                      builder: (context, _) => BlocProvider<TitleCubit>(
                        create: (_) {
                          final cubit = getIt<TitleCubit>();
                          unawaited(cubit.loadTitles());
                          return cubit;
                        },
                        child: const TitleListPage(),
                      ),
                      routes: [
                        GoRoute(
                          path: Routes.idSegment,
                          builder: (context, state) {
                            final id = state.pathParameters['id'] ?? '';
                            return BlocProvider<TitleDetailCubit>(
                              create: (_) {
                                final cubit = getIt<TitleDetailCubit>();
                                unawaited(cubit.loadTitle(id));
                                return cubit;
                              },
                              child: TitleDetailPage(titleId: id),
                            );
                          },
                        ),
                      ],
                    ),
                    GoRoute(
                      path: Routes.copiesSegment,
                      builder: (context, _) => BlocProvider<CopyCubit>(
                        create: (_) {
                          final cubit = getIt<CopyCubit>();
                          unawaited(cubit.loadCopies());
                          return cubit;
                        },
                        child: const CopyListPage(),
                      ),
                    ),
                    GoRoute(
                      path: Routes.labelsSegment,
                      builder: (context, _) => const LabelPrintPage(),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.circulation,
                  redirect: (_, state) => state.uri.path == Routes.circulation
                      ? Routes.circulationCheckOut
                      : null,
                  routes: [
                    GoRoute(
                      path: Routes.checkOutSegment,
                      builder: (context, _) => BlocProvider<CheckOutCubit>(
                        create: (_) => getIt<CheckOutCubit>(),
                        child: const CheckOutPage(),
                      ),
                    ),
                    GoRoute(
                      path: Routes.returnsSegment,
                      builder: (context, _) => BlocProvider<ReturnCubit>(
                        create: (_) => getIt<ReturnCubit>(),
                        child: const ReturnPage(),
                      ),
                    ),
                    GoRoute(
                      path: Routes.reservationsSegment,
                      builder: (context, _) =>
                          BlocProvider<ReservationListCubit>(
                            create: (_) {
                              final cubit = getIt<ReservationListCubit>();
                              unawaited(cubit.loadReservations());
                              return cubit;
                            },
                            child: const ReservationListPage(),
                          ),
                    ),
                    GoRoute(
                      path: Routes.finesSegment,
                      builder: (context, _) => BlocProvider<FineListCubit>(
                        create: (_) {
                          final cubit = getIt<FineListCubit>();
                          unawaited(cubit.loadFines());
                          return cubit;
                        },
                        child: const FineListPage(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.members,
                  builder: (context, _) => BlocProvider<MemberCubit>(
                    create: (_) {
                      final cubit = getIt<MemberCubit>();
                      unawaited(cubit.loadMembers());
                      return cubit;
                    },
                    child: const MemberListPage(),
                  ),
                  routes: [
                    GoRoute(
                      path: Routes.idSegment,
                      builder: (context, state) {
                        final id = state.pathParameters['id'] ?? '';
                        return BlocProvider<MemberDetailCubit>(
                          create: (_) {
                            final cubit = getIt<MemberDetailCubit>();
                            unawaited(cubit.loadMember(id));
                            return cubit;
                          },
                          child: MemberDetailPage(memberId: id),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            // StatefulShellBranch(
            //   routes: [
            //     GoRoute(
            //       path: Routes.opac,
            //       builder: (context, _) => const OpacPage(),
            //     ),
            //   ],
            // ),
            // StatefulShellBranch(
            //   routes: [
            //     GoRoute(
            //       path: Routes.reports,
            //       builder: (context, _) => const ReportsPage(),
            //     ),
            //   ],
            // ),
            // StatefulShellBranch(
            //   routes: [
            //     GoRoute(
            //       path: Routes.users,
            //       builder: (context, _) => const UserListPage(),
            //       routes: [
            //         GoRoute(
            //           path: Routes.rolesSegment,
            //           builder: (context, _) => const RoleListPage(),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.settings,
                  redirect: (_, state) => state.uri.path == Routes.settings
                      ? Routes.settingsLibrary
                      : null,
                  routes: [
                    GoRoute(
                      path: Routes.librarySegment,
                      builder: (context, _) =>
                          BlocProvider<LibraryProfileCubit>(
                            create: (_) {
                              final cubit = getIt<LibraryProfileCubit>();
                              unawaited(cubit.loadProfile());
                              return cubit;
                            },
                            child: const LibraryProfilePage(),
                          ),
                    ),
                    GoRoute(
                      path: Routes.loanRulesSegment,
                      builder: (context, _) => BlocProvider<LoanRulesCubit>(
                        create: (_) {
                          final cubit = getIt<LoanRulesCubit>();
                          unawaited(cubit.loadRules());
                          return cubit;
                        },
                        child: const LoanRulesPage(),
                      ),
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
      AuthStatus.signedOut =>
        location == Routes.signIn || location == Routes.recoverPassword
            ? null
            : Routes.signIn,
      AuthStatus.signedIn =>
        Routes.isAuthLocation(location) ? Routes.dashboard : null,
    };
  }
}
