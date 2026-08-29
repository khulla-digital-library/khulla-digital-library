import 'package:khulla/core/config/flavor.dart';

/// Immutable, per-flavor runtime configuration.
///
/// Resolved once at startup in the flavor entrypoint and registered in the
/// service locator so the database and other services can depend on it.
///
/// Khulla stores its data on the device, so a flavor mostly decides *which*
/// database file the app opens — running the dev build must never touch a
/// real library's catalogue.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.databaseFileName,
    required this.windowTitle,
  });

  factory AppConfig.dev() => const AppConfig(
    flavor: Flavor.dev,
    databaseFileName: 'khulla_dev.db',
    windowTitle: 'Khulla (dev)',
  );

  factory AppConfig.prod() => const AppConfig(
    flavor: Flavor.prod,
    databaseFileName: 'khulla.db',
    windowTitle: 'Khulla',
  );

  /// Which build this is.
  final Flavor flavor;

  /// SQLite file name, resolved against the platform's application support
  /// directory on native and used as the IndexedDB store name on web.
  final String databaseFileName;

  /// Native window title on desktop. Ignored on mobile and web.
  final String windowTitle;

  /// Whether this is the release flavor. Gates verbose logging.
  bool get isProduction => flavor == Flavor.prod;
}
