import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:khulla/app/app.dart';
import 'package:khulla/app/bloc_observer.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/core/logging/app_logger.dart';
import 'package:khulla/core/window/window_setup.dart';

/// Shared startup for every flavor: installs error and bloc observers, sizes
/// the desktop window, wires up dependency injection for the given [config],
/// opens the local database, then runs the app.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.verbose = !config.isProduction;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (details.silent) return;
    AppLogger.error(
      details.exception,
      stackTrace: details.stack ?? StackTrace.empty,
      source: 'FlutterError',
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      error,
      stackTrace: stack,
      source: 'PlatformDispatcher',
      fatal: true,
    );
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  // Sized and shown before the first frame so desktop never flashes a
  // default-sized white window. No-op on web and mobile.
  await configureAppWindow(config);

  await configureDependencies(config);

  await _runApp();
}

/// Opens the database and starts the app, falling back to a readable failure
/// screen rather than a crash when the catalogue cannot be reached.
Future<void> _runApp() async {
  try {
    await guardDatabase(
      getIt<AppDatabase>().open,
      source: 'bootstrap',
    );
  } on AppException catch (error, stackTrace) {
    AppLogger.error(
      error,
      stackTrace: stackTrace,
      source: 'bootstrap',
      fatal: true,
    );
    runApp(
      StartupFailureApp(
        error: error,
        onRetry: () => unawaited(_runApp()),
      ),
    );
    return;
  }

  runApp(const App());
}
