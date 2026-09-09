import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';

/// Drift access to `members` and the aggregates shown on list rows.
abstract interface class MemberLocalDataSource {
  Future<MemberListResult> findMembers(MemberQuery query);

  Future<Member?> findMemberById(String id);

  Future<Member?> findMemberByCardNumber(String cardNumber);

  Future<Member> insertMember(Member member, {required String searchText});

  Future<Member> updateMember(Member member, {required String searchText});

  Future<void> archiveMember(String id, DateTime archivedAt);

  Future<bool> hasCirculationHistory(String memberId);

  Future<void> deleteMember(String id);
}
