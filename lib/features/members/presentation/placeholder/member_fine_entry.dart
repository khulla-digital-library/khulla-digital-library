import 'package:khulla/core/money/money.dart';

/// One charge on a member's record.
///
/// Deliberately thinner than circulation's own `FineRecord`: the register
/// shows what is owed and against which work, and leaves the reason
/// vocabulary — which circulation owns — on the fines ledger.
class MemberFineEntry {
  const MemberFineEntry({
    required this.id,
    required this.amount,
    required this.raised,
    required this.isPaid,
    this.titleName,
  });

  final String id;

  final Money amount;
  final String raised;
  final bool isPaid;
  final String? titleName;
}
