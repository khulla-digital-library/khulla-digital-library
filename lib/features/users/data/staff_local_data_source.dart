import 'package:khulla/features/users/domain/models/staff_credentials.dart';
import 'package:khulla/features/users/domain/models/staff_member.dart';

/// Reads and writes staff accounts in the local catalogue.
abstract interface class StaffLocalDataSource {
  /// Whether any staff account exists.
  ///
  /// This is the setup gate the router gates on, so it is a count and not a
  /// full read: on a fresh install it has to answer before the first frame.
  Future<bool> hasAnyStaff();

  /// Every account, oldest first — the order the desk was staffed in.
  Future<List<StaffMember>> findAllStaff();

  /// One account, or null when the id names nothing.
  Future<StaffMember?> findStaffById(String id);

  /// The account for [email] together with its password hash, or null when no
  /// account holds that address. [email] is normalized here, so a caller may
  /// pass exactly what the operator typed.
  Future<StaffCredentials?> findCredentialsByEmail(String email);

  /// Writes [staff] with [passwordHash] and returns it.
  ///
  /// Throws a `DuplicateRecordException` when the email is already held.
  Future<StaffMember> insertStaff(
    StaffMember staff, {
    required String passwordHash,
  });
}
