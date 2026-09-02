import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/members/domain/member_category.dart';
import 'package:khulla/features/members/domain/member_status.dart';
import 'package:khulla/features/members/presentation/placeholder/member_activity.dart';
import 'package:khulla/features/members/presentation/placeholder/member_fine_entry.dart';
import 'package:khulla/features/members/presentation/placeholder/member_record.dart';

/// Stand-in borrowers until the `members` table exists.
///
/// One of each standing, on purpose — an active card, one expiring, one
/// lapsed, one suspended for what it owes — so the register is laid out
/// against the states that actually turn up at a desk.
final List<MemberRecord> placeholderMembers = [
  MemberRecord(
    id: 'm-1',
    name: 'Anita Rai',
    cardNumber: 'KH-M-0104',
    category: MemberCategory.public,
    status: MemberStatus.active,
    joined: '14 Feb 2024',
    expires: '14 Feb 2027',
    loansOut: 2,
    overdue: 0,
    finesOwed: Money.major(15),
    borrowedAllTime: 48,
    email: 'anita.rai@example.com',
    phone: '+977 98 4501 2233',
    address: 'Jhamsikhel, Lalitpur',
  ),
  MemberRecord(
    id: 'm-2',
    name: 'Bikash Thapa',
    cardNumber: 'KH-M-0211',
    category: MemberCategory.student,
    status: MemberStatus.suspended,
    joined: '02 Jul 2023',
    expires: '02 Jul 2026',
    loansOut: 1,
    overdue: 1,
    finesOwed: Money.major(70),
    borrowedAllTime: 96,
    email: 'bikash.thapa@example.com',
    phone: '+977 98 1122 8890',
    address: 'Baneshwor, Kathmandu',
    notes: 'Card suspended until the overdue copy comes back.',
  ),
  const MemberRecord(
    id: 'm-3',
    name: 'Sunita Gurung',
    cardNumber: 'KH-M-0318',
    category: MemberCategory.teacher,
    status: MemberStatus.active,
    joined: '09 Jan 2022',
    expires: '09 Jan 2027',
    loansOut: 1,
    overdue: 0,
    finesOwed: Money.zero,
    borrowedAllTime: 212,
    email: 'sunita.gurung@example.com',
    phone: '+977 98 6677 1204',
    address: 'Pulchowk, Lalitpur',
  ),
  const MemberRecord(
    id: 'm-4',
    name: 'Prakash Adhikari',
    cardNumber: 'KH-M-0402',
    category: MemberCategory.student,
    status: MemberStatus.expiring,
    joined: '21 Sep 2023',
    expires: '21 Sep 2026',
    loansOut: 1,
    overdue: 0,
    finesOwed: Money.zero,
    borrowedAllTime: 64,
    email: 'prakash.adhikari@example.com',
    phone: '+977 98 3344 5566',
  ),
  MemberRecord(
    id: 'm-5',
    name: 'Nisha Karki',
    cardNumber: 'KH-M-0455',
    category: MemberCategory.public,
    status: MemberStatus.active,
    joined: '30 Mar 2025',
    expires: '30 Mar 2027',
    loansOut: 1,
    overdue: 1,
    finesOwed: Money.major(35),
    borrowedAllTime: 12,
    phone: '+977 98 7788 4412',
    address: 'Chabahil, Kathmandu',
  ),
  const MemberRecord(
    id: 'm-6',
    name: 'Dipak Shahi',
    cardNumber: 'KH-M-0509',
    category: MemberCategory.child,
    status: MemberStatus.active,
    joined: '05 May 2025',
    expires: '05 May 2027',
    loansOut: 1,
    overdue: 0,
    finesOwed: Money.zero,
    borrowedAllTime: 9,
    dateOfBirth: '11 Nov 2016',
    guardian: 'Sarita Shahi',
    phone: '+977 98 2211 6677',
  ),
  MemberRecord(
    id: 'm-7',
    name: 'Ramesh Shrestha',
    cardNumber: 'KH-M-0533',
    category: MemberCategory.public,
    status: MemberStatus.expired,
    joined: '18 Jun 2021',
    expires: '18 Jun 2026',
    loansOut: 0,
    overdue: 0,
    finesOwed: Money.major(1200),
    borrowedAllTime: 133,
    email: 'ramesh.shrestha@example.com',
    address: 'Bhaktapur',
    notes: 'Owes a replacement cost for a copy reported lost.',
  ),
  const MemberRecord(
    id: 'm-8',
    name: 'Kamala Bhandari',
    cardNumber: 'KH-M-0570',
    category: MemberCategory.teacher,
    status: MemberStatus.active,
    joined: '27 Oct 2024',
    expires: '27 Oct 2026',
    loansOut: 0,
    overdue: 0,
    finesOwed: Money.zero,
    borrowedAllTime: 27,
    email: 'kamala.bhandari@example.com',
    phone: '+977 98 9900 1122',
  ),
];

/// The copies a member is holding, shown on their record.
final List<MemberLoanEntry> placeholderMemberLoans = [
  const MemberLoanEntry(
    id: 'ml-1',
    titleName: 'Palpasa Café',
    barcode: 'KH-000182',
    issued: '31 Aug 2026',
    due: '01 Sep 2026',
    fine: Money.zero,
  ),
  const MemberLoanEntry(
    id: 'ml-2',
    titleName: 'Everest: Beyond the Limit',
    barcode: 'KH-000640',
    issued: '01 Sep 2026',
    due: '01 Sep 2026',
    fine: Money.zero,
  ),
];

/// What they have borrowed and brought back.
final List<MemberLoanEntry> placeholderMemberHistory = [
  MemberLoanEntry(
    id: 'mh-1',
    titleName: 'Muna Madan',
    barcode: 'KH-000181',
    issued: '02 Jul 2026',
    due: '16 Jul 2026',
    fine: Money.major(15),
    isOverdue: true,
    returned: '19 Jul 2026',
  ),
  const MemberLoanEntry(
    id: 'mh-2',
    titleName: 'A Brief History of Time',
    barcode: 'KH-000701',
    issued: '04 Jun 2026',
    due: '18 Jun 2026',
    fine: Money.zero,
    returned: '15 Jun 2026',
  ),
  const MemberLoanEntry(
    id: 'mh-3',
    titleName: 'Sapiens',
    barcode: 'KH-000501',
    issued: '11 May 2026',
    due: '25 May 2026',
    fine: Money.zero,
    returned: '23 May 2026',
  ),
];

/// The charges on their record.
final List<MemberFineEntry> placeholderMemberFines = [
  MemberFineEntry(
    id: 'mf-1',
    amount: Money.major(15),
    raised: '19 Jul 2026',
    isPaid: false,
    titleName: 'Muna Madan',
  ),
];

/// The member behind an id, falling back to the first record so a deep link
/// to an id that no longer exists renders a page rather than a crash. The
/// real screen answers this with a not-found state from the query instead.
MemberRecord placeholderMemberById(String id) => placeholderMembers.firstWhere(
  (member) => member.id == id,
  orElse: () => placeholderMembers.first,
);
