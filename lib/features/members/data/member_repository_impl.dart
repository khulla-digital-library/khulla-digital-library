import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_fine.dart';
import 'package:khulla/features/circulation/shared/domain/resolve_loan_rules.dart';
import 'package:khulla/features/members/data/member_local_data_source.dart';
import 'package:khulla/features/members/data/member_type_local_data_source.dart';
import 'package:khulla/features/members/domain/member_repository.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';
import 'package:khulla/features/settings/domain/loan_rules_repository.dart';
import 'package:khulla/shared/utils/search_text.dart';
import 'package:uuid/uuid.dart';

/// [MemberRepository] over the local catalogue.
///
/// Merges member-type labels and loan-rule defaults on save; circulation
/// aggregates on list rows come from [MemberLocalDataSource].
@LazySingleton(as: MemberRepository)
class MemberRepositoryImpl implements MemberRepository {
  MemberRepositoryImpl(
    this._dataSource,
    this._memberTypes,
    this._loanRules,
  );

  final MemberLocalDataSource _dataSource;
  final MemberTypeLocalDataSource _memberTypes;
  final LoanRulesRepository _loanRules;

  static const Uuid _uuid = Uuid();

  @override
  Future<MemberListResult> findMembers(MemberQuery query) =>
      _dataSource.findMembers(query);

  @override
  Future<Member?> findMember(String id) => _dataSource.findMemberById(id);

  @override
  Future<Member?> findMemberByCardNumber(String cardNumber) =>
      _dataSource.findMemberByCardNumber(cardNumber);

  @override
  Future<Member> saveMember({
    required String fullName,
    required String cardNumber,
    required String memberTypeId,
    String? id,
    bool sendNotices = true,
    DateTime? dateOfBirth,
    String? email,
    String? phone,
    String? address,
    String? guardian,
    String? notes,
  }) async {
    final now = DateTime.now();
    final recordId = id ?? _uuid.v4();
    final existing = id == null ? null : await _dataSource.findMemberById(id);
    final memberType = await _memberTypes.findMemberTypeById(memberTypeId);
    if (memberType == null) {
      throw const NotFoundException('That member type was not found.');
    }

    final search = buildSearchText([
      fullName,
      cardNumber,
      email ?? '',
      phone ?? '',
      address ?? '',
      guardian ?? '',
    ]);

    final joinedAt = existing?.joinedAt ?? now;
    var expiresAt = existing?.expiresAt;
    if (existing == null) {
      final defaults = await _loanRules.findRules();
      if (defaults == null) {
        throw const NotFoundException('Loan rules have not been configured.');
      }
      final rules = resolveLoanRules(defaults, memberType);
      expiresAt = _membershipExpiresAt(
        joinedAt,
        rules.membershipDurationMonths,
      );
    }

    final draft = Member(
      id: recordId,
      fullName: fullName.trim(),
      cardNumber: cardNumber.trim(),
      memberTypeId: memberTypeId,
      memberTypeName: memberType.name,
      memberTypeCode: memberType.code,
      joinedAt: joinedAt,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      loansOut: existing?.loansOut ?? 0,
      overdueLoans: existing?.overdueLoans ?? 0,
      finesOwed: existing?.finesOwed ?? Money.zero,
      borrowedAllTime: existing?.borrowedAllTime ?? 0,
      sendNotices: sendNotices,
      dateOfBirth: dateOfBirth == null ? null : dateOnly(dateOfBirth),
      email: email?.trim(),
      phone: phone?.trim(),
      address: address?.trim(),
      guardian: guardian?.trim(),
      notes: notes?.trim(),
      expiresAt: expiresAt,
      suspendedAt: existing?.suspendedAt,
      suspensionReason: existing?.suspensionReason,
      archivedAt: existing?.archivedAt,
    );

    if (existing == null) {
      return await _dataSource.insertMember(draft, searchText: search);
    }
    return await _dataSource.updateMember(draft, searchText: search);
  }

  @override
  Future<void> archiveMember(String id) =>
      _dataSource.archiveMember(id, DateTime.now());

  @override
  Future<Member> suspendMember(String id, {String? reason}) async {
    final existing = await _dataSource.findMemberById(id);
    if (existing == null) {
      throw const NotFoundException('That member was not found.');
    }
    if (existing.suspendedAt != null) {
      throw const ConflictException('That membership is already suspended.');
    }
    final now = DateTime.now();
    return await _dataSource.updateMember(
      existing.copyWith(
        suspendedAt: now,
        suspensionReason: reason?.trim(),
        updatedAt: now,
      ),
      searchText: _searchText(existing),
    );
  }

  @override
  Future<Member> unsuspendMember(String id) async {
    final existing = await _dataSource.findMemberById(id);
    if (existing == null) {
      throw const NotFoundException('That member was not found.');
    }
    if (existing.suspendedAt == null) {
      throw const ConflictException('That membership is not suspended.');
    }
    final now = DateTime.now();
    return await _dataSource.updateMember(
      existing.copyWith(
        suspendedAt: null,
        suspensionReason: null,
        updatedAt: now,
      ),
      searchText: _searchText(existing),
    );
  }

  @override
  Future<Member> renewMembership(String id) async {
    final existing = await _dataSource.findMemberById(id);
    if (existing == null) {
      throw const NotFoundException('That member was not found.');
    }
    final memberType = await _memberTypes.findMemberTypeById(
      existing.memberTypeId,
    );
    if (memberType == null) {
      throw const NotFoundException('That member type was not found.');
    }
    final defaults = await _loanRules.findRules();
    if (defaults == null) {
      throw const NotFoundException('Loan rules have not been configured.');
    }
    final rules = resolveLoanRules(defaults, memberType);
    final now = DateTime.now();
    final base = existing.expiresAt ?? dateOnly(now);
    final renewed = _membershipExpiresAt(base, rules.membershipDurationMonths);
    return await _dataSource.updateMember(
      existing.copyWith(expiresAt: renewed, updatedAt: now),
      searchText: _searchText(existing),
    );
  }

  String _searchText(Member member) => buildSearchText([
    member.fullName,
    member.cardNumber,
    member.email ?? '',
    member.phone ?? '',
    member.address ?? '',
    member.guardian ?? '',
  ]);

  @override
  Future<void> removeMember(String id) async {
    if (await _dataSource.hasCirculationHistory(id)) {
      throw const ConflictException(
        'That member has circulation history and cannot be deleted.',
      );
    }
    await _dataSource.deleteMember(id);
  }

  DateTime _membershipExpiresAt(DateTime joinedAt, int months) {
    final start = dateOnly(joinedAt);
    var year = start.year;
    var month = start.month + months;
    while (month > 12) {
      month -= 12;
      year++;
    }
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = start.day > lastDay ? lastDay : start.day;
    return DateTime(year, month, day);
  }
}
