import 'package:injectable/injectable.dart';
import 'package:khulla/features/catalog/copy/data/copy_local_data_source.dart';
import 'package:khulla/features/catalog/copy/domain/copy_repository.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy_query.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: CopyRepository)
class CopyRepositoryImpl implements CopyRepository {
  CopyRepositoryImpl(this._dataSource);

  final CopyLocalDataSource _dataSource;
  static const Uuid _uuid = Uuid();

  @override
  Future<CopyListResult> findCopies(CopyQuery query) =>
      _dataSource.findCopies(query);

  @override
  Future<List<Copy>> findCopiesByTitleId(String titleId) =>
      _dataSource.findCopiesByTitleId(titleId);

  @override
  Future<Copy?> findCopyByBarcode(String barcode) =>
      _dataSource.findCopyByBarcode(barcode);

  @override
  Future<Copy> addCopy({
    required String titleId,
    required String titleName,
    String? shelf,
    CopyCondition condition = CopyCondition.good,
    String? barcode,
    String? notes,
  }) async {
    final now = DateTime.now();
    return await _dataSource.insertCopy(
      copy: Copy(
        id: _uuid.v4(),
        barcode: barcode ?? '',
        titleId: titleId,
        titleName: titleName,
        shelf: shelf?.trim() ?? '',
        condition: condition,
        status: CopyStatus.available,
        acquiredAt: now,
        notes: notes?.trim(),
      ),
      barcodeOverride: barcode?.trim(),
    );
  }

  @override
  Future<void> archiveCopy(String id) =>
      _dataSource.archiveCopy(id, DateTime.now());
}
