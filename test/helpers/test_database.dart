import 'package:drift/native.dart';
import 'package:khulla/core/database/app_database.dart';

/// In-memory catalogue opened for integration tests.
Future<AppDatabase> openTestDatabase() async {
  final db = AppDatabase.connect(NativeDatabase.memory());
  await db.warmUp();
  return db;
}

/// Closes a database opened with [openTestDatabase].
Future<void> closeTestDatabase(AppDatabase db) => db.close();
