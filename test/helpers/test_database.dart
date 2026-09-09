import 'package:drift/native.dart';
import 'package:khulla/core/database/app_database.dart';

/// Opens an in-memory [AppDatabase] for integration tests.
///
/// Runs [AppDatabase.warmUp] so migrations execute before the first assertion,
/// matching production startup. Pair with [closeTestDatabase] in `tearDown`.
Future<AppDatabase> openTestDatabase() async {
  final db = AppDatabase.connect(NativeDatabase.memory());
  await db.warmUp();
  return db;
}

/// Closes a database opened with [openTestDatabase].
Future<void> closeTestDatabase(AppDatabase db) => db.close();
