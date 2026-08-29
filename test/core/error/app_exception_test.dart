import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Database db;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    // A real in-memory SQLite, not a mock: the point of these tests is that
    // the driver's own error strings classify correctly, which a hand-written
    // fake would beg the question on.
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('''
      CREATE TABLE shelf (id INTEGER PRIMARY KEY, code TEXT NOT NULL UNIQUE)
    ''');
    await db.execute('''
      CREATE TABLE book (
        id INTEGER PRIMARY KEY,
        shelf_id INTEGER NOT NULL REFERENCES shelf (id)
      )
    ''');
  });

  tearDown(() => db.close());

  group('AppException.fromDatabaseException', () {
    test('maps a unique violation to DuplicateRecordException', () async {
      await db.insert('shelf', {'code': 'A-1'});

      await expectLater(
        guardDatabase(() => db.insert('shelf', {'code': 'A-1'})),
        throwsA(isA<DuplicateRecordException>()),
      );
    });

    test('maps a NOT NULL violation to InvalidInputException', () async {
      await expectLater(
        guardDatabase(() => db.insert('shelf', {'code': null})),
        throwsA(isA<InvalidInputException>()),
      );
    });

    test('maps an unclassified failure to DatabaseFailureException', () async {
      // A foreign-key violation is a real constraint error with no dedicated
      // predicate on the driver, so it must land in the catch-all rather than
      // escaping as a raw driver exception.
      await expectLater(
        guardDatabase(() => db.insert('book', {'shelf_id': 404})),
        throwsA(isA<DatabaseFailureException>()),
      );
    });

    test('maps use after close to DatabaseUnavailableException', () async {
      await db.close();

      await expectLater(
        guardDatabase(() => db.query('shelf')),
        throwsA(isA<DatabaseUnavailableException>()),
      );

      // Reopen so tearDown's close() has something valid to act on.
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    });
  });

  group('guardDatabase', () {
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
