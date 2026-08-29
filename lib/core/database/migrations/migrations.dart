import 'package:khulla/core/database/migrations/migration.dart';

/// Every schema migration, in ascending [Migration.version] order.
///
/// Adding a table or column is two steps: write the [Migration], then append
/// it here. `AppDatabase` derives the schema version from this list, so there
/// is no second number to keep in sync.
///
/// The list is empty because no domain table has been designed yet — a fresh
/// install opens an empty database at version 1. The first migration to land
/// takes `version => 1`.
const List<Migration> appMigrations = <Migration>[];

/// Schema version the app expects, derived from [appMigrations].
///
/// SQLite reserves 0 for "brand new", so an empty migration list still
/// reports 1.
int get appSchemaVersion =>
    appMigrations.isEmpty ? 1 : appMigrations.last.version;

/// Fails fast in debug when [appMigrations] is not a gapless ascending run
/// from 1.
///
/// Two branches that each add "the next migration" merge cleanly and produce
/// duplicate versions, which SQLite cannot detect — one of the two silently
/// never runs.
bool debugMigrationsAreWellOrdered() {
  for (var index = 0; index < appMigrations.length; index++) {
    if (appMigrations[index].version != index + 1) return false;
  }
  return true;
}
