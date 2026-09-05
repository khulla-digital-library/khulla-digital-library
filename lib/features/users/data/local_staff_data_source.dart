import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/features/users/data/mappers/staff_row_mappers.dart';
import 'package:khulla/features/users/data/staff_local_data_source.dart';
import 'package:khulla/features/users/domain/models/staff_credentials.dart';
import 'package:khulla/features/users/domain/models/staff_member.dart';

/// Drift-backed [StaffLocalDataSource].
@LazySingleton(as: StaffLocalDataSource)
class LocalStaffDataSource implements StaffLocalDataSource {
  LocalStaffDataSource(this._db);

  final AppDatabase _db;

  static const String _source = 'LocalStaffDataSource';

  /// Trimmed and lower-cased, so the unique index treats one address as one
  /// account however it was typed. Applied on every read and every write —
  /// normalizing on only one side is how a lookup starts missing rows.
  static String normalizeEmail(String email) => email.trim().toLowerCase();

  @override
  Future<bool> hasAnyStaff() => guardDatabase(
    () async {
      final count = _db.staff.id.count();
      final row = await (_db.selectOnly(
        _db.staff,
      )..addColumns([count])).getSingle();
      return (row.read(count) ?? 0) > 0;
    },
    source: '$_source.hasAnyStaff',
  );

  @override
  Future<List<StaffMember>> findAllStaff() => guardDatabase(
    () async {
      final rows =
          await (_db.select(_db.staff)..orderBy([
                (staff) => OrderingTerm(expression: staff.createdAt),
              ]))
              .get();
      return rows.map((row) => row.toDomain()).toList();
    },
    source: '$_source.findAllStaff',
  );

  @override
  Future<StaffMember?> findStaffById(String id) => guardDatabase(
    () async {
      final row = await (_db.select(
        _db.staff,
      )..where((staff) => staff.id.equals(id))).getSingleOrNull();
      return row?.toDomain();
    },
    source: '$_source.findStaffById',
  );

  @override
  Future<StaffCredentials?> findCredentialsByEmail(String email) =>
      guardDatabase(
        () async {
          final row =
              await (_db.select(_db.staff)..where(
                    (staff) => staff.email.equals(normalizeEmail(email)),
                  ))
                  .getSingleOrNull();
          return row?.toCredentials();
        },
        source: '$_source.findCredentialsByEmail',
      );

  @override
  Future<StaffMember> insertStaff(
    StaffMember staff, {
    required String passwordHash,
  }) => guardDatabase(
    () async {
      final normalized = staff.copyWith(email: normalizeEmail(staff.email));
      await _db
          .into(_db.staff)
          .insert(normalized.toCompanion(passwordHash: passwordHash));
      return normalized;
    },
    source: '$_source.insertStaff',
  );
}
