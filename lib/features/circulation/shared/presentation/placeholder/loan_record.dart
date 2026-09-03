import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';

/// One copy currently out of the building.
///
/// [accruedFine] is a [Money], never a number: a rupee `double` drifts across
/// a year of daily accrual, and the desk's whole job here is to be right
/// about what somebody owes.
class LoanRecord {
  const LoanRecord({
    required this.id,
    required this.barcode,
    required this.titleName,
    required this.memberName,
    required this.memberId,
    required this.issued,
    required this.due,
    required this.status,
    required this.accruedFine,
    this.daysLate = 0,
    this.renewals = 0,
  });

  final String id;
  final String barcode;
  final String titleName;
  final String memberName;
  final String memberId;
  final String issued;
  final String due;
  final LoanStatus status;

  /// What the loan has cost so far. Zero until it is late.
  final Money accruedFine;

  /// How far past its due date it is.
  final int daysLate;

  /// How many times it has already been extended.
  final int renewals;
}
