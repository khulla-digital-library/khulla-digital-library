import 'package:khulla/features/members/domain/models/member_type.dart';

/// Reference rows for member-type pickers, rule overrides and bootstrap seeding.
abstract interface class MemberTypeLocalDataSource {
  Future<int> countMemberTypes();

  Future<List<MemberType>> findActiveMemberTypes();

  Future<MemberType?> findMemberTypeById(String id);

  Future<MemberType> insertMemberType(MemberType type);
}
