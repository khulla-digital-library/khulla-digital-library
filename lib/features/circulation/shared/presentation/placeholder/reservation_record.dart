import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';

/// One member waiting for a copy.
class ReservationRecord {
  const ReservationRecord({
    required this.id,
    required this.memberName,
    required this.memberId,
    required this.titleName,
    required this.titleId,
    required this.placed,
    required this.queuePosition,
    required this.status,
    this.expires,
  });

  final String id;
  final String memberName;
  final String memberId;
  final String titleName;
  final String titleId;
  final String placed;

  /// Where they sit in the queue for this title, first is one.
  final int queuePosition;

  final ReservationStatus status;

  /// When the copy leaves the hold shelf. Only set once it is ready.
  final String? expires;
}
