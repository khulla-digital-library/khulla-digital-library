import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/logging/app_logger.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqlite;

/// Runs [action], converting anything it throws into an [AppException].
///
/// Every data-source method that touches the database wraps its body in this
/// so a cubit only ever has to catch [AppException]. An [AppException] thrown
/// deliberately inside [action] — a domain rule rejecting the write — passes
/// through untouched.
///
/// ```dart
/// Future<List<Book>> findAll() => guardDatabase(
///   () async {
///     final rows = await _db.database.query(BookTable.name);
///     return rows.map(BookMapper.toDomain).toList();
///   },
///   source: 'BookLocalDataSource.findAll',
/// );
/// ```
Future<T> guardDatabase<T>(
  Future<T> Function() action, {
  String? source,
}) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } on sqlite.DatabaseException catch (error, stackTrace) {
    AppLogger.warn(
      'Database call failed',
      source: source,
      error: error,
      stackTrace: stackTrace,
    );
    throw AppException.fromDatabaseException(error);
  } on Object catch (error, stackTrace) {
    AppLogger.error(error, stackTrace: stackTrace, source: source);
    throw const UnknownException();
  }
}
