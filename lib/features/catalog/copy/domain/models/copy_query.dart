import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';

part 'copy_query.freezed.dart';

@freezed
abstract class CopyQuery with _$CopyQuery {
  const factory CopyQuery({
    @Default('') String search,
    String? titleId,
    @Default(<CopyStatus>{}) Set<CopyStatus> statuses,
    @Default('barcode') String sortColumn,
    @Default(true) bool sortAscending,
    @Default(0) int offset,
    @Default(8) int limit,
  }) = _CopyQuery;
}

typedef CopyListResult = ({List<Copy> items, int totalCount});
