/// One past loan of a title, as its history table renders it.
///
/// Circulation owns loans; this is the read the catalogue needs of them, kept
/// here so the two features do not reach into each other's placeholder data.
class TitleHistoryEntry {
  const TitleHistoryEntry({
    required this.id,
    required this.member,
    required this.barcode,
    required this.borrowed,
    this.returned,
    this.wasLate = false,
  });

  final String id;
  final String member;
  final String barcode;
  final String borrowed;

  /// Null while the copy is still out.
  final String? returned;

  /// Whether it came back after its due date.
  final bool wasLate;
}

/// Stand-in loan history, shown on every title's page until circulation has
/// a table behind it.
const List<TitleHistoryEntry> placeholderTitleHistory = [
  TitleHistoryEntry(
    id: 'h-1',
    member: 'Anita Rai',
    barcode: 'KH-000182',
    borrowed: '31 Aug 2026',
  ),
  TitleHistoryEntry(
    id: 'h-2',
    member: 'Bikash Thapa',
    barcode: 'KH-000183',
    borrowed: '04 Aug 2026',
  ),
  TitleHistoryEntry(
    id: 'h-3',
    member: 'Sunita Gurung',
    barcode: 'KH-000181',
    borrowed: '02 Jul 2026',
    returned: '19 Jul 2026',
    wasLate: true,
  ),
  TitleHistoryEntry(
    id: 'h-4',
    member: 'Prakash Adhikari',
    barcode: 'KH-000181',
    borrowed: '11 Jun 2026',
    returned: '24 Jun 2026',
  ),
];
