import 'package:flutter_test/flutter_test.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/security/password_hasher.dart';
import 'package:khulla/core/security/recovery_code.dart';
import 'package:khulla/features/users/data/local_staff_data_source.dart';
import 'package:khulla/features/users/data/staff_repository_impl.dart';
import 'package:khulla/features/users/domain/user_role.dart';

import '../helpers/test_database.dart';

void main() {
  late AppDatabase db;
  late StaffRepositoryImpl repository;

  setUp(() async {
    db = await openTestDatabase();
    repository = StaffRepositoryImpl(
      LocalStaffDataSource(db),
      PasswordHasher(),
    );
  });

  tearDown(() => closeTestDatabase(db));

  test('resetPasswordWithRecoveryCode spends one code and signs in', () async {
    final codes = RecoveryCode.generateSet();
    await repository.createStaff(
      name: 'Ram',
      email: 'ram@lib.np',
      password: 'correct-horse',
      role: UserRole.administrator,
      recoveryCodes: codes,
    );

    expect(await repository.hasUnusedRecoveryCodes(), isTrue);
    expect(
      await repository.signIn(email: 'ram@lib.np', password: 'wrong'),
      isNull,
    );

    final recovered = await repository.resetPasswordWithRecoveryCode(
      email: 'ram@lib.np',
      recoveryCode: codes.first.toLowerCase(),
      newPassword: 'new-password',
    );
    expect(recovered, isNotNull);
    expect(recovered!.email, 'ram@lib.np');

    expect(
      await repository.resetPasswordWithRecoveryCode(
        email: 'ram@lib.np',
        recoveryCode: codes.first,
        newPassword: 'another-password',
      ),
      isNull,
    );

    expect(
      await repository.signIn(email: 'ram@lib.np', password: 'correct-horse'),
      isNull,
    );
    final signedIn = await repository.signIn(
      email: 'ram@lib.np',
      password: 'new-password',
    );
    expect(signedIn, isNotNull);

    expect(await repository.hasUnusedRecoveryCodes(), isTrue);
  });

  test('resetPasswordWithRecoveryCode returns null for a wrong code', () async {
    await repository.createStaff(
      name: 'Sita',
      email: 'sita@lib.np',
      password: 'correct-horse',
      role: UserRole.administrator,
      recoveryCodes: RecoveryCode.generateSet(),
    );

    expect(
      await repository.resetPasswordWithRecoveryCode(
        email: 'sita@lib.np',
        recoveryCode: 'AAAA-AAAA-AAAA-AAAA',
        newPassword: 'new-password',
      ),
      isNull,
    );
    expect(
      await repository.signIn(email: 'sita@lib.np', password: 'correct-horse'),
      isNotNull,
    );
  });
}
