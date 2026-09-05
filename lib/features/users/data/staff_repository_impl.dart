import 'package:injectable/injectable.dart';
import 'package:khulla/core/security/password_hasher.dart';
import 'package:khulla/features/users/data/staff_local_data_source.dart';
import 'package:khulla/features/users/domain/models/staff_member.dart';
import 'package:khulla/features/users/domain/staff_repository.dart';
import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/domain/user_status.dart';
import 'package:uuid/uuid.dart';

/// [StaffRepository] over the local catalogue.
///
/// The password never travels further than this class: it arrives from a
/// form, is hashed or verified here, and the data source below only ever
/// handles the digest.
@LazySingleton(as: StaffRepository)
class StaffRepositoryImpl implements StaffRepository {
  StaffRepositoryImpl(this._dataSource, this._hasher);

  final StaffLocalDataSource _dataSource;
  final PasswordHasher _hasher;

  static const Uuid _uuid = Uuid();

  @override
  Future<bool> hasAnyStaff() => _dataSource.hasAnyStaff();

  @override
  Future<List<StaffMember>> findAllStaff() => _dataSource.findAllStaff();

  @override
  Future<StaffMember?> findStaffById(String id) =>
      _dataSource.findStaffById(id);

  @override
  Future<StaffMember> createStaff({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) => _dataSource.insertStaff(
    StaffMember(
      id: _uuid.v4(),
      name: name.trim(),
      email: email,
      role: role,
      status: UserStatus.active,
      createdAt: DateTime.now(),
    ),
    passwordHash: _hasher.hash(password),
  );

  @override
  Future<StaffMember?> signIn({
    required String email,
    required String password,
  }) async {
    final credentials = await _dataSource.findCredentialsByEmail(email);
    if (credentials == null) return null;
    if (!_hasher.verify(password, credentials.passwordHash)) return null;
    // A disabled or never-accepted account is not a sign-in, and saying so
    // would confirm the address exists. The desk re-enables it instead.
    if (!credentials.staff.canSignIn) return null;
    return credentials.staff;
  }
}
