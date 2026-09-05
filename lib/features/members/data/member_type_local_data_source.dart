import 'package:khulla/features/members/domain/models/member_type.dart';

abstract interface class MemberTypeLocalDataSource {
  Future<int> countMemberTypes();

  Future<List<MemberType>> findActiveMemberTypes();

  Future<MemberType?> findMemberTypeById(String id);

  Future<MemberType> insertMemberType(MemberType type);
}
