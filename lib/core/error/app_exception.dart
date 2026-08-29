import 'package:equatable/equatable.dart';
import 'package:sqflite_common/sqlite_api.dart' as sqlite;

/// Typed, user-presentable failures surfaced by the data layer.
///
/// The data layer catches driver-level errors and converts them with
/// [AppException.fromDatabaseException] so presentation code only ever deals
/// with this small, exhaustive set of cases. The `message` carried here is a
/// developer-facing fallback — presentation should render
/// `AppExceptionL10n.localizedMessage` instead.
sealed class AppException extends Equatable implements Exception {
  const AppException(this.message);

  /// Maps a SQLite driver error onto the closest domain-level failure.
  ///
  /// The driver reports constraint violations as ordinary errors, but they
  /// mean different things to a librarian: a unique violation is "that
  /// accession number already exists", a foreign-key violation is "that
  /// record is still referenced". Classifying here keeps that judgement out
  /// of every repository.
  factory AppException.fromDatabaseException(sqlite.DatabaseException error) {
    if (error.isUniqueConstraintError()) {
      return DuplicateRecordException(error.toString());
    }
    if (error.isNotNullConstraintError()) {
      return const InvalidInputException();
    }
    if (error.isDatabaseClosedError()) {
      return const DatabaseUnavailableException();
    }
    if (error.isReadOnlyError()) {
      return const DatabaseUnavailableException(
        'The library database is read-only.',
      );
    }
    return DatabaseFailureException(error.toString());
  }

  /// Developer-facing fallback copy. Not for display.
  final String message;

  @override
  List<Object?> get props => [message];
}

/// A write violated a uniqueness rule — a duplicate ISBN, accession number,
/// or membership id.
class DuplicateRecordException extends AppException {
  const DuplicateRecordException([String? message])
    : super(message ?? 'That record already exists.');
}

/// The requested record does not exist, or was deleted by another window.
class NotFoundException extends AppException {
  const NotFoundException([String? message])
    : super(message ?? 'We could not find that.');
}

/// The payload failed a domain rule before or during persistence.
class InvalidInputException extends AppException {
  const InvalidInputException([String? message])
    : super(message ?? 'Some of those details are not valid.');
}

/// The action conflicts with the current state — returning a copy that is not
/// on loan, borrowing one that is already out.
class ConflictException extends AppException {
  const ConflictException([String? message])
    : super(message ?? 'That action conflicts with the current record.');
}

/// The database could not be opened, was closed underneath a query, or is
/// read-only. Distinct from a failed statement: nothing will work until it is
/// resolved.
class DatabaseUnavailableException extends AppException {
  const DatabaseUnavailableException([String? message])
    : super(message ?? 'The library database is unavailable.');
}

/// A statement failed for a reason we could not classify further.
class DatabaseFailureException extends AppException {
  const DatabaseFailureException([String? message])
    : super(message ?? 'The database rejected that change.');
}

/// Reading or writing a file failed — a cover image, an import, an export.
class StorageException extends AppException {
  const StorageException([String? message])
    : super(message ?? 'A file could not be read or written.');
}

/// Anything we could not classify.
class UnknownException extends AppException {
  const UnknownException() : super('An unexpected error occurred.');
}
