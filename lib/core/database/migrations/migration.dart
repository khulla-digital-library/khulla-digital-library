import 'package:sqflite_common/sqlite_api.dart';

/// One forward, irreversible step of the database schema.
///
/// Migrations are append-only: once a version has shipped, its [up] is
/// frozen — someone's catalogue was built by running exactly that SQL, and
/// editing it would silently diverge their schema from a fresh install's.
/// Correcting a mistake means adding the next migration, never rewriting an
/// old one.
///
/// ```dart
/// class CreateBooksTable implements Migration {
///   const CreateBooksTable();
///
///   @override
///   int get version => 1;
///
///   @override
///   String get description => 'Create the books table';
///
///   @override
///   Future<void> up(DatabaseExecutor db) => db.execute('''
///     CREATE TABLE books (
///       id TEXT PRIMARY KEY NOT NULL,
///       title TEXT NOT NULL
///     )
///   ''');
/// }
/// ```
abstract interface class Migration {
  /// Schema version this migration brings the database *to*. Starts at 1 and
  /// increases by one per migration, with no gaps.
  int get version;

  /// Short human-readable summary, used in startup logs.
  String get description;

  /// Applies the change. Runs inside the transaction sqflite opens around the
  /// whole create/upgrade, so a throw rolls back every migration in the run.
  Future<void> up(DatabaseExecutor db);
}
