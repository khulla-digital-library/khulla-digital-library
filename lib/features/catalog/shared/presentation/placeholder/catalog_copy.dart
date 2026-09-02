import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';

/// One physical item on a shelf.
///
/// The barcode is the identifier the desk actually works with — a checkout
/// scans a copy, never a title — so it leads every row and every search hint
/// in the copies screens.
class CatalogCopy {
  const CatalogCopy({
    required this.id,
    required this.barcode,
    required this.titleId,
    required this.titleName,
    required this.shelf,
    required this.condition,
    required this.status,
    required this.acquired,
    this.borrower,
    this.dueDate,
  });

  final String id;
  final String barcode;
  final String titleId;
  final String titleName;
  final String shelf;
  final CopyCondition condition;
  final CopyStatus status;
  final String acquired;

  /// Who is holding it, while it is out.
  final String? borrower;

  /// When it is due back, while it is out.
  final String? dueDate;
}
