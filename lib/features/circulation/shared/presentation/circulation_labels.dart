import 'package:khulla/features/circulation/shared/domain/fine_reason.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Localized names and semantic tones for circulation's enums.
///
/// Kept on the presentation side, like the catalogue's: the enums say what a
/// loan is, this file says how it reads and which colour family it draws
/// from.
extension LoanStatusX on LoanStatus {
  String label(AppLocalizations l10n) => switch (this) {
    LoanStatus.onLoan => l10n.statusOnLoan,
    LoanStatus.dueToday => l10n.statusDueToday,
    LoanStatus.overdue => l10n.statusOverdue,
    LoanStatus.returned => l10n.statusReturned,
  };

  AppStatusTone get tone => switch (this) {
    LoanStatus.onLoan => AppStatusTone.brand,
    LoanStatus.dueToday => AppStatusTone.warning,
    LoanStatus.overdue => AppStatusTone.danger,
    LoanStatus.returned => AppStatusTone.success,
  };

  IconData get icon => switch (this) {
    LoanStatus.onLoan => Icons.swap_horiz_rounded,
    LoanStatus.dueToday => Icons.event_rounded,
    LoanStatus.overdue => Icons.error_outline_rounded,
    LoanStatus.returned => Icons.check_circle_outline_rounded,
  };
}

extension ReservationStatusX on ReservationStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ReservationStatus.waiting => l10n.reservationsStatusWaiting,
    ReservationStatus.ready => l10n.reservationsStatusReady,
    ReservationStatus.expired => l10n.reservationsStatusExpired,
  };

  AppStatusTone get tone => switch (this) {
    ReservationStatus.waiting => AppStatusTone.info,
    ReservationStatus.ready => AppStatusTone.success,
    ReservationStatus.expired => AppStatusTone.neutral,
  };
}

extension FineStatusX on FineStatus {
  String label(AppLocalizations l10n) => switch (this) {
    FineStatus.unpaid => l10n.finesStatusUnpaid,
    FineStatus.paid => l10n.finesStatusPaid,
    FineStatus.waived => l10n.finesStatusWaived,
  };

  AppStatusTone get tone => switch (this) {
    FineStatus.unpaid => AppStatusTone.danger,
    FineStatus.paid => AppStatusTone.success,
    FineStatus.waived => AppStatusTone.neutral,
  };
}

extension FineReasonX on FineReason {
  String label(AppLocalizations l10n) => switch (this) {
    FineReason.overdue => l10n.finesReasonOverdue,
    FineReason.damage => l10n.finesReasonDamage,
    FineReason.lost => l10n.finesReasonLost,
    FineReason.membership => l10n.finesReasonMembership,
  };

  IconData get icon => switch (this) {
    FineReason.overdue => Icons.schedule_rounded,
    FineReason.damage => Icons.report_gmailerrorred_rounded,
    FineReason.lost => Icons.help_outline_rounded,
    FineReason.membership => Icons.card_membership_rounded,
  };
}
