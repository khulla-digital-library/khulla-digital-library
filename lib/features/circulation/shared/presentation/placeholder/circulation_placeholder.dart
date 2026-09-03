import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/shared/domain/fine_reason.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/fine_record.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/loan_record.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/reservation_record.dart';

/// Stand-in circulation records for every desk screen.
///
/// The mix is deliberate: loans in all three live states, a hold that is
/// ready and one that has expired, and a fine of each kind — so the screens
/// are laid out against a real Tuesday rather than a tidy sample. The lists
/// are `final` because [Money.major] is not a const constructor.
final List<LoanRecord> placeholderLoans = [
  LoanRecord(
    id: 'l-1',
    barcode: 'KH-000183',
    titleName: 'Palpasa Café',
    memberName: 'Bikash Thapa',
    memberId: 'm-2',
    issued: '04 Aug 2026',
    due: '18 Aug 2026',
    status: LoanStatus.overdue,
    accruedFine: Money.major(70),
    daysLate: 14,
  ),
  LoanRecord(
    id: 'l-2',
    barcode: 'KH-000502',
    titleName: 'Sapiens',
    memberName: 'Nisha Karki',
    memberId: 'm-5',
    issued: '11 Aug 2026',
    due: '25 Aug 2026',
    status: LoanStatus.overdue,
    accruedFine: Money.major(35),
    daysLate: 7,
    renewals: 1,
  ),
  const LoanRecord(
    id: 'l-3',
    barcode: 'KH-000182',
    titleName: 'Palpasa Café',
    memberName: 'Anita Rai',
    memberId: 'm-1',
    issued: '31 Aug 2026',
    due: '01 Sep 2026',
    status: LoanStatus.dueToday,
    accruedFine: Money.zero,
  ),
  const LoanRecord(
    id: 'l-4',
    barcode: 'KH-000211',
    titleName: 'Things Fall Apart',
    memberName: 'Sunita Gurung',
    memberId: 'm-3',
    issued: '26 Aug 2026',
    due: '09 Sep 2026',
    status: LoanStatus.onLoan,
    accruedFine: Money.zero,
  ),
  const LoanRecord(
    id: 'l-5',
    barcode: 'KH-000456',
    titleName: 'Introduction to Algorithms',
    memberName: 'Prakash Adhikari',
    memberId: 'm-4',
    issued: '08 Sep 2026',
    due: '22 Sep 2026',
    status: LoanStatus.onLoan,
    accruedFine: Money.zero,
    renewals: 2,
  ),
  const LoanRecord(
    id: 'l-6',
    barcode: 'KH-000640',
    titleName: 'Everest: Beyond the Limit',
    memberName: 'Anita Rai',
    memberId: 'm-1',
    issued: '01 Sep 2026',
    due: '01 Sep 2026',
    status: LoanStatus.dueToday,
    accruedFine: Money.zero,
  ),
  const LoanRecord(
    id: 'l-7',
    barcode: 'KH-000181',
    titleName: 'Muna Madan',
    memberName: 'Dipak Shahi',
    memberId: 'm-6',
    issued: '29 Aug 2026',
    due: '12 Sep 2026',
    status: LoanStatus.onLoan,
    accruedFine: Money.zero,
  ),
];

/// The hold queue.
const List<ReservationRecord> placeholderReservations = [
  ReservationRecord(
    id: 'r-1',
    memberName: 'Sunita Gurung',
    memberId: 'm-3',
    titleName: 'Palpasa Café',
    titleId: 't-1',
    placed: '28 Aug 2026',
    queuePosition: 1,
    status: ReservationStatus.ready,
    expires: '04 Sep 2026',
  ),
  ReservationRecord(
    id: 'r-2',
    memberName: 'Prakash Adhikari',
    memberId: 'm-4',
    titleName: 'Palpasa Café',
    titleId: 't-1',
    placed: '30 Aug 2026',
    queuePosition: 2,
    status: ReservationStatus.waiting,
  ),
  ReservationRecord(
    id: 'r-3',
    memberName: 'Nisha Karki',
    memberId: 'm-5',
    titleName: 'Things Fall Apart',
    titleId: 't-2',
    placed: '21 Aug 2026',
    queuePosition: 1,
    status: ReservationStatus.waiting,
  ),
  ReservationRecord(
    id: 'r-4',
    memberName: 'Dipak Shahi',
    memberId: 'm-6',
    titleName: 'Sapiens',
    titleId: 't-5',
    placed: '02 Aug 2026',
    queuePosition: 1,
    status: ReservationStatus.expired,
    expires: '16 Aug 2026',
  ),
];

/// The fines ledger.
final List<FineRecord> placeholderFines = [
  FineRecord(
    id: 'f-1',
    memberName: 'Bikash Thapa',
    memberId: 'm-2',
    reason: FineReason.overdue,
    amount: Money.major(70),
    raised: '19 Aug 2026',
    status: FineStatus.unpaid,
    titleName: 'Palpasa Café',
  ),
  FineRecord(
    id: 'f-2',
    memberName: 'Nisha Karki',
    memberId: 'm-5',
    reason: FineReason.overdue,
    amount: Money.major(35),
    raised: '26 Aug 2026',
    status: FineStatus.unpaid,
    titleName: 'Sapiens',
  ),
  FineRecord(
    id: 'f-3',
    memberName: 'Ramesh Shrestha',
    memberId: 'm-7',
    reason: FineReason.lost,
    amount: Money.major(1200),
    raised: '12 Aug 2026',
    status: FineStatus.unpaid,
    titleName: 'Things Fall Apart',
  ),
  FineRecord(
    id: 'f-4',
    memberName: 'Sunita Gurung',
    memberId: 'm-3',
    reason: FineReason.damage,
    amount: Money.major(250),
    raised: '05 Aug 2026',
    status: FineStatus.paid,
    titleName: 'Things Fall Apart',
  ),
  FineRecord(
    id: 'f-5',
    memberName: 'Anita Rai',
    memberId: 'm-1',
    reason: FineReason.overdue,
    amount: Money.major(15),
    raised: '28 Jul 2026',
    status: FineStatus.waived,
    titleName: 'Muna Madan',
  ),
  FineRecord(
    id: 'f-6',
    memberName: 'Dipak Shahi',
    memberId: 'm-6',
    reason: FineReason.membership,
    amount: Money.major(500),
    raised: '01 Jul 2026',
    status: FineStatus.paid,
  ),
];

/// Loans in one standing, for the desk's counts and filters.
List<LoanRecord> placeholderLoansWith(LoanStatus status) => [
  for (final loan in placeholderLoans)
    if (loan.status == status) loan,
];

/// What every unpaid fine adds up to.
///
/// [Money.sum] rather than a fold over doubles: totalling in minor units is
/// exact, and the screen never sees a rounding error it has to explain.
Money get placeholderOutstandingFines => Money.sum([
  for (final fine in placeholderFines)
    if (fine.status == FineStatus.unpaid) fine.amount,
]);

/// What was taken at the desk this month.
Money get placeholderCollectedFines => Money.sum([
  for (final fine in placeholderFines)
    if (fine.status == FineStatus.paid) fine.amount,
]);

/// What was written off this month.
Money get placeholderWaivedFines => Money.sum([
  for (final fine in placeholderFines)
    if (fine.status == FineStatus.waived) fine.amount,
]);
