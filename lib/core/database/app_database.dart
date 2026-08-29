import 'package:injectable/injectable.dart';
import 'package:khulla/core/config/app_config.dart';
import 'package:khulla/core/database/database_platform.dart';
import 'package:khulla/core/database/migrations/migrations.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/logging/app_logger.dart';
import 'package:sqflite_common/sqlite_api.dart';

/// Owns the single SQLite connection for the app's lifetime.
///
/// Khulla keeps the whole catalogue on the device, so this is the equivalent
/// of the network client in a server-backed app: opened once during
/// `bootstrap`, injected into data sources, and never reached for from a
/// widget.
///
/// Data sources take this class, not a raw [Database], so the connection can
/// be reopened (after a restore, or an import that swaps the file) without
/// every collaborator holding a stale handle.
@lazySingleton
class AppDatabase {
  AppDatabase(this._config);

  static const String _source = 'AppDatabase';

  final AppConfig _config;

  Database? _connection;

  /// The open connection.
  ///
  /// Throws [DatabaseUnavailableException] when called before [open]
  /// completes, which is a wiring bug rather than a runtime condition —
  /// `bootstrap` opens the database before the first frame.
  Database get database {
    final connection = _connection;
    if (connection == null || !connection.isOpen) {
      throw const DatabaseUnavailableException(
        'The database was used before it was opened.',
      );
    }
    return connection;
  }

  /// Whether a usable connection is currently held.
  bool get isOpen => _connection?.isOpen ?? false;

  /// Opens the database, creating or migrating the schema as needed.
  ///
  /// Idempotent: calling it on an already-open connection returns the same
  /// handle rather than opening a second one.
  Future<Database> open() async {
    final existing = _connection;
    if (existing != null && existing.isOpen) return existing;

    assert(
      debugMigrationsAreWellOrdered(),
      'appMigrations must be a gapless ascending run starting at version 1. '
      'Two branches that each appended "the next" migration will collide here.',
    );

    final factory = await resolveDatabaseFactory();
    final path = await resolveDatabasePath(_config.databaseFileName);

    AppLogger.info(
      'Opening database at $path (schema v$appSchemaVersion)',
      source: _source,
    );

    final connection = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: appSchemaVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
      ),
    );

    _connection = connection;
    return connection;
  }

  /// Closes the connection. Safe to call when already closed.
  @disposeMethod
  Future<void> close() async {
    final connection = _connection;
    _connection = null;
    if (connection == null || !connection.isOpen) return;
    await connection.close();
  }

  /// Runs before any create/upgrade callback, on every open.
  Future<void> _onConfigure(Database db) async {
    // SQLite defaults foreign keys to OFF, per connection. Without this a
    // delete would orphan every loan pointing at the record instead of
    // failing, and the constraint would exist only as documentation.
    await db.execute('PRAGMA foreign_keys = ON');

    if (supportsWriteAheadLog) {
      await db.execute('PRAGMA journal_mode = WAL');
    }
  }

  /// Fresh install: run every migration from the beginning.
  Future<void> _onCreate(Database db, int version) =>
      _apply(db, from: 0, to: version);

  /// Existing install on an older schema: run only what it has not seen.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) =>
      _apply(db, from: oldVersion, to: newVersion);

  /// An older build opened a newer database.
  ///
  /// sqflite's stock handler for this is `onDatabaseDowngradeDelete`, which
  /// deletes the file. For a library's only copy of its catalogue that is
  /// unacceptable — refuse to open instead, and let the operator reinstall
  /// the newer build or restore a backup.
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) {
    AppLogger.error(
      'Database schema v$oldVersion is newer than this build expects '
      '(v$newVersion). Refusing to open so no data is lost.',
      source: _source,
      fatal: true,
    );
    throw const DatabaseUnavailableException(
      'This library file was created by a newer version of Khulla.',
    );
  }

  /// Applies every migration whose version falls in `(from, to]`.
  Future<void> _apply(
    DatabaseExecutor db, {
    required int from,
    required int to,
  }) async {
    for (final migration in appMigrations) {
      if (migration.version <= from || migration.version > to) continue;
      AppLogger.info(
        'Migrating to v${migration.version}: ${migration.description}',
        source: _source,
      );
      await migration.up(db);
    }
  }
}
