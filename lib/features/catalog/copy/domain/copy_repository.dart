import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy_query.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';

abstract interface class CopyRepository {
  Future<CopyListResult> findCopies(CopyQuery query);

  Future<List<Copy>> findCopiesByTitleId(String titleId);

  Future<Copy?> findCopyByBarcode(String barcode);

  Future<Copy> addCopy({
    required String titleId,
    required String titleName,
    String? shelf,
    CopyCondition condition,
    String? barcode,
    String? notes,
  });

  Future<void> archiveCopy(String id);
}
