import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:sqlite3/common.dart';

SqliteException _sqliteError(int extendedResultCode) => SqliteException(
  extendedResultCode: extendedResultCode,
  message: 'test',
);

void main() {
  group('AppException.fromSqlite', () {
    test('maps a unique violation to DuplicateRecordException', () {
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_UNIQUE),
        ),
        isA<DuplicateRecordException>(),
      );
    });

    test('maps a primary-key violation to DuplicateRecordException', () {
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_PRIMARYKEY),
        ),
        isA<DuplicateRecordException>(),
      );
    });

    test('maps a foreign-key violation to ConflictException', () {
      // "That record is still referenced" — deleting an author who still has
      // titles is a conflict with the current state, not a failed write.
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_FOREIGNKEY),
        ),
        isA<ConflictException>(),
      );
    });

    test('maps NOT NULL and CHECK violations to InvalidInputException', () {
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_NOTNULL),
        ),
        isA<InvalidInputException>(),
      );
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_CHECK),
        ),
        isA<InvalidInputException>(),
      );
    });

    test('maps an unrecognised constraint to DatabaseFailureException', () {
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_CONSTRAINT_TRIGGER),
        ),
        isA<DatabaseFailureException>(),
      );
    });

    test('reads busy and locked from the primary code', () {
      // The extended variants (BUSY_SNAPSHOT, READONLY_ROLLBACK, …) all mean
      // the same thing to us, so they must not fall through to the catch-all.
      expect(
        AppException.fromSqlite(
          _sqliteError(SqlExtendedError.SQLITE_BUSY_SNAPSHOT),
        ),
        isA<DatabaseUnavailableException>(),
      );
      expect(
        AppException.fromSqlite(_sqliteError(SqlError.SQLITE_LOCKED)),
        isA<DatabaseUnavailableException>(),
      );
    });

    test('maps a read-only database to DatabaseUnavailableException', () {
      expect(
        AppException.fromSqlite(_sqliteError(SqlError.SQLITE_READONLY)),
        isA<DatabaseUnavailableException>(),
      );
    });

    test('maps a damaged file to DatabaseUnavailableException', () {
      expect(
        AppException.fromSqlite(_sqliteError(SqlError.SQLITE_CORRUPT)),
        isA<DatabaseUnavailableException>(),
      );
      expect(
        AppException.fromSqlite(_sqliteError(SqlError.SQLITE_NOTADB)),
        isA<DatabaseUnavailableException>(),
      );
    });

    test('maps anything unclassified to DatabaseFailureException', () {
      expect(
        AppException.fromSqlite(_sqliteError(SqlError.SQLITE_ERROR)),
        isA<DatabaseFailureException>(),
      );
    });
  });

  group('guardDatabase', () {
    // A real in-memory SQLite, not a mock: the point is that drift's own
    // errors classify correctly, which a hand-written fake would beg the
    // question on.
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.connect(NativeDatabase.memory());
      await db.customStatement(
        'CREATE TABLE shelf (id INTEGER PRIMARY KEY, code TEXT NOT NULL UNIQUE)',
      );
      await db.customStatement(
        'CREATE TABLE book (id INTEGER PRIMARY KEY, '
        'shelf_id INTEGER NOT NULL REFERENCES shelf (id))',
      );
    });

    tearDown(() => db.close());

    test('classifies a unique violation from a live database', () async {
      await db.customStatement("INSERT INTO shelf (code) VALUES ('A-1')");

      await expectLater(
        guardDatabase<void>(
          () => db.customStatement("INSERT INTO shelf (code) VALUES ('A-1')"),
        ),
        throwsA(isA<DuplicateRecordException>()),
      );
    });

    test('enforces foreign keys, and calls that a conflict', () async {
      // beforeOpen turns foreign keys on. Without it this insert succeeds and
      // the constraint exists only as documentation.
      await expectLater(
        guardDatabase<void>(
          () => db.customStatement('INSERT INTO book (shelf_id) VALUES (404)'),
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('passes a deliberate AppException through untouched', () async {
      await expectLater(
        guardDatabase<void>(() async => throw const ConflictException()),
        throwsA(isA<ConflictException>()),
      );
    });

    test('converts an unrelated error to UnknownException', () async {
      await expectLater(
        guardDatabase<void>(() async => throw const FormatException()),
        throwsA(isA<UnknownException>()),
      );
    });
  });
}
