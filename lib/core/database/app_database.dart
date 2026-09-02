import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/database/connection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/logging/app_logger.dart';

part 'app_database.g.dart';

/// Owns the single SQLite connection for the app's lifetime.
///
/// Khulla keeps the whole catalogue on the device, so this is the equivalent
/// of the network client in a server-backed app: constructed once during
/// `bootstrap`, injected into data sources, and never reached for from a
/// widget.
///
/// Data sources take this class rather than a raw executor, so the connection
/// can be swapped (after a restore, or an import that replaces the file)
/// without every collaborator holding a stale handle.
@lazySingleton
// Tables are added here as each catalog sub-feature lands; `make migrate`
// records the resulting schema.
@DriftDatabase()
class AppDatabase extends _$AppDatabase {
  AppDatabase(AppConfig config) : super(openDatabaseConnection(config));

  /// Opens an arbitrary executor — an in-memory database in tests, a second
  /// file during an import.
  @visibleForTesting
  AppDatabase.connect(super.e);

  static const String _source = 'AppDatabase';

  /// Bumped by exactly one per shipped schema change, alongside a step in
  /// `app_database.steps.dart` recorded by `make migrate`.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: _createSchema,
    onUpgrade: _upgradeSchema,
    beforeOpen: (_) async {
      // SQLite defaults foreign keys to OFF, per connection. Without this a
      // delete would orphan every loan pointing at the record instead of
      // failing, and the constraint would exist only as documentation.
      //
      // It cannot be set inside a transaction, which is why it lives here
      // rather than in a migration.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Forces the connection open and runs migrations now, rather than on the
  /// first query.
  ///
  /// Drift connects lazily. `bootstrap` needs any failure — a locked file, a
  /// full disk, a schema from a newer build — *before* the first frame, so it
  /// can show `StartupFailureApp` instead of a screen that throws once the
  /// operator taps something.
  Future<void> warmUp() => customSelect('SELECT 1').get();

  @disposeMethod
  Future<void> dispose() => close();

  Future<void> _createSchema(Migrator m) async {
    AppLogger.info(
      'Creating catalogue schema v$schemaVersion',
      source: _source,
    );
    await m.createAll();
  }

  Future<void> _upgradeSchema(Migrator m, int from, int to) async {
    // Drift routes downgrades through onUpgrade with `from > to`; unlike
    // sqflite there is no separate hook, so the refusal is ours to write.
    // The stock behaviour elsewhere is to delete and recreate the file, which
    // for a library's only copy of its catalogue is unacceptable — refuse to
    // open, and let the operator reinstall the newer build or restore a
    // backup.
    if (from > to) {
      AppLogger.error(
        'Catalogue schema v$from is newer than this build expects (v$to). '
        'Refusing to open so no data is lost.',
        source: _source,
        fatal: true,
      );
      throw const DatabaseUnavailableException(
        'This library file was created by a newer version of Khulla Digital Library.',
      );
    }

    AppLogger.info('Migrating catalogue from v$from to v$to', source: _source);

    // Once the first schema change ships, `make migrate` writes the steps and
    // this becomes:
    //
    // ```dart
    // await stepByStep(from1To2: (m, schema) async { ... })(m, from, to);
    // ```
    //
    // Steps take their own schema snapshot as an argument and must never
    // touch `this` — referring to the live database inside a step silently
    // uses today's schema instead of that version's, which is how a migration
    // passes in development and corrupts a real upgrade.
  }
}
