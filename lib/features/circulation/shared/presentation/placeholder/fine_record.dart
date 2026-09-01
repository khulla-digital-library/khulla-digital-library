import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/shared/domain/fine_reason.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';

/// One charge against a member.
class FineRecord {
  const FineRecord({
    required this.id,
    required this.memberName,
    required this.memberId,
    required this.reason,
    required this.amount,
    required this.raised,
    required this.status,
    this.titleName,
  });

  final String id;
  final String memberName;
  final String memberId;
  final FineReason reason;

  /// What is owed, in minor units. Displayed with `amount.display()` — never
  /// interpolated, which would print the paisa.
  final Money amount;

  final String raised;
  final FineStatus status;

  /// The work the charge came from, where there is one. A membership fee has
  /// none.
  final String? titleName;
}
