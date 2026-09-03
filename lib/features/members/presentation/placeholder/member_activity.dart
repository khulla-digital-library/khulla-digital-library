import 'package:khulla/core/money/money.dart';

/// One copy a member is holding, as their record renders it.
///
/// Circulation owns loans; this is the read the register needs of them, kept
/// here so the two features do not reach into each other's placeholder data.
class MemberLoanEntry {
  const MemberLoanEntry({
    required this.id,
    required this.titleName,
    required this.barcode,
    required this.issued,
    required this.due,
    required this.fine,
    this.isOverdue = false,
    this.returned,
  });

  final String id;
  final String titleName;
  final String barcode;
  final String issued;
  final String due;

  /// What the loan has cost so far.
  final Money fine;

  final bool isOverdue;

  /// Null while the copy is still out.
  final String? returned;
}
