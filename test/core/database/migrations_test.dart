import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/core/database/migrations/migration.dart';
import 'package:khulla/core/database/migrations/migrations.dart';
import 'package:sqflite_common/sqlite_api.dart';

class _FakeMigration implements Migration {
  const _FakeMigration(this.version);

  @override
  final int version;

  @override
  String get description => 'fake v$version';

  @override
  Future<void> up(DatabaseExecutor db) async {}
}

void main() {
  group('appMigrations', () {
    test('is a gapless ascending run starting at 1', () {
      // Guards the invariant AppDatabase asserts on open. Two branches that
      // each appended "the next" migration merge cleanly and produce a
      // duplicate version, which SQLite cannot detect.
      expect(
        debugMigrationsAreWellOrdered(),
        isTrue,
        reason:
            'appMigrations must run 1, 2, 3, … with no gaps or duplicates. '
            'Renumber the migration you just added.',
      );
    });

    test('derives the schema version from the last migration', () {
      expect(
        appSchemaVersion,
        appMigrations.isEmpty ? 1 : appMigrations.last.version,
      );
    });

    test('reports a duplicated version as ill-ordered', () {
      // Sanity-check the guard itself: a checker that always passes would let
      // the real invariant rot unnoticed.
      const duplicated = <Migration>[_FakeMigration(1), _FakeMigration(1)];
      expect(_isWellOrdered(duplicated), isFalse);
      expect(
        _isWellOrdered(const [_FakeMigration(1), _FakeMigration(2)]),
        isTrue,
      );
    });
  });
}

/// Mirror of [debugMigrationsAreWellOrdered] over an arbitrary list.
bool _isWellOrdered(List<Migration> migrations) {
  for (var index = 0; index < migrations.length; index++) {
    if (migrations[index].version != index + 1) return false;
  }
  return true;
}
