import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/members/domain/models/member.dart';

extension MemberRowMapper on MemberRow {
  Member toDomain({
    required String memberTypeName,
    required int loansOut,
    required int overdueLoans,
    required Money finesOwed,
    required int borrowedAllTime,
    String? memberTypeCode,
  }) => Member(
    id: id,
    fullName: fullName,
    cardNumber: cardNumber,
    memberTypeId: memberTypeId,
    memberTypeName: memberTypeName,
    memberTypeCode: memberTypeCode,
    joinedAt: joinedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
    loansOut: loansOut,
    overdueLoans: overdueLoans,
    finesOwed: finesOwed,
    borrowedAllTime: borrowedAllTime,
    sendNotices: sendNotices,
    dateOfBirth: dateOfBirth,
    email: email,
    phone: phone,
    address: address,
    guardian: guardian,
    notes: notes,
    expiresAt: expiresAt,
    suspendedAt: suspendedAt,
    suspensionReason: suspensionReason,
    archivedAt: archivedAt,
  );
}

extension MemberDomainMapper on Member {
  MembersCompanion toCompanion({required String searchText}) =>
      MembersCompanion(
        id: Value(id),
        cardNumber: Value(cardNumber),
        fullName: Value(fullName),
        memberTypeId: Value(memberTypeId),
        dateOfBirth: Value(dateOfBirth),
        email: Value(email),
        phone: Value(phone),
        address: Value(address),
        guardian: Value(guardian),
        notes: Value(notes),
        joinedAt: Value(joinedAt),
        expiresAt: Value(expiresAt),
        suspendedAt: Value(suspendedAt),
        suspensionReason: Value(suspensionReason),
        sendNotices: Value(sendNotices),
        searchText: Value(searchText),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        archivedAt: Value(archivedAt),
      );
}
