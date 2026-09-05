import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';

abstract interface class MemberRepository {
  Future<MemberListResult> findMembers(MemberQuery query);

  Future<Member?> findMember(String id);

  Future<Member?> findMemberByCardNumber(String cardNumber);

  Future<Member> saveMember({
    required String fullName,
    required String cardNumber,
    required String memberTypeId,
    String? id,
    bool sendNotices,
    DateTime? dateOfBirth,
    String? email,
    String? phone,
    String? address,
    String? guardian,
    String? notes,
  });

  Future<void> archiveMember(String id);

  Future<void> removeMember(String id);
}
