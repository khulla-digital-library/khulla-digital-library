import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';

extension LoanRowMapper on LoanRow {
  Loan toDomain({
    String? barcode,
    String? titleId,
    String? titleName,
    String? memberName,
  }) => Loan(
    id: id,
    copyId: copyId,
    memberId: memberId,
    checkedOutAt: checkedOutAt,
    dueAt: dueAt,
    returnedAt: returnedAt,
    renewalCount: renewalCount,
    returnCondition: returnCondition,
    checkedOutByStaffId: checkedOutByStaffId,
    returnedByStaffId: returnedByStaffId,
    ruleLoanPeriodDays: ruleLoanPeriodDays,
    ruleFinePerDay: ruleFinePerDay,
    ruleGraceDays: ruleGraceDays,
    ruleMaximumFine: ruleMaximumFine,
    createdAt: createdAt,
    barcode: barcode,
    titleId: titleId,
    titleName: titleName,
    memberName: memberName,
  );
}

extension LoanDomainMapper on Loan {
  LoansCompanion toCompanion() => LoansCompanion(
    id: Value(id),
    copyId: Value(copyId),
    memberId: Value(memberId),
    checkedOutAt: Value(checkedOutAt),
    dueAt: Value(dueAt),
    returnedAt: Value(returnedAt),
    renewalCount: Value(renewalCount),
    returnCondition: Value(returnCondition),
    checkedOutByStaffId: Value(checkedOutByStaffId),
    returnedByStaffId: Value(returnedByStaffId),
    ruleLoanPeriodDays: Value(ruleLoanPeriodDays),
    ruleFinePerDay: Value(ruleFinePerDay),
    ruleGraceDays: Value(ruleGraceDays),
    ruleMaximumFine: Value(ruleMaximumFine),
    createdAt: Value(createdAt),
  );
}
