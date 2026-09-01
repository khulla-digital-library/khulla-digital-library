import 'package:khulla/core/money/money.dart';

/// The lending rules a new loan is created under.
///
/// The rates are [Money], not numbers: a fine of "five" is meaningless
/// without a unit, and a rupee `double` accruing daily drifts within a year.
class LoanRules {
  const LoanRules({
    required this.loanPeriodDays,
    required this.renewalLimit,
    required this.borrowingLimit,
    required this.finePerDay,
    required this.graceDays,
    required this.maximumFine,
    required this.holdShelfDays,
    required this.blockOverdueBorrowers,
    required this.autoRenewWhenUnreserved,
  });

  final int loanPeriodDays;
  final int renewalLimit;
  final int borrowingLimit;

  /// What one late day costs.
  final Money finePerDay;

  /// How many late days are forgiven before the fine starts.
  final int graceDays;

  /// The ceiling on one copy's fine, however late it gets.
  final Money maximumFine;

  /// How long a copy waits on the hold shelf before the next member gets it.
  final int holdShelfDays;

  final bool blockOverdueBorrowers;
  final bool autoRenewWhenUnreserved;
}
