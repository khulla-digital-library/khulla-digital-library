import 'package:khulla/features/users/domain/models/staff_member.dart';
import 'package:khulla/features/users/domain/user_role.dart';

/// Staff accounts and the sign-in that authenticates against them.
abstract interface class StaffRepository {
  /// Whether the library has been set up — that is, whether any staff account
  /// exists. False sends the operator to first-run onboarding.
  Future<bool> hasAnyStaff();

  /// Every account, oldest first.
  Future<List<StaffMember>> findAllStaff();

  /// One account, or null when the id names nothing. Used to restore a saved
  /// session, which is why a missing account is a value and not a failure.
  Future<StaffMember?> findStaffById(String id);

  /// Creates an account with a freshly hashed password.
  ///
  /// Throws a `DuplicateRecordException` when the email is already held.
  Future<StaffMember> createStaff({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });

  /// The account for [email] when [password] verifies against it, and null
  /// when either the address or the password is wrong.
  ///
  /// One null for both cases on purpose: telling a caller which half was
  /// wrong tells anyone holding the file which addresses are real accounts.
  Future<StaffMember?> signIn({
    required String email,
    required String password,
  });
}
