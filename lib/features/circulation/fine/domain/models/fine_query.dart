import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';

part 'fine_query.freezed.dart';

@freezed
abstract class FineQuery with _$FineQuery {
  const factory FineQuery({
    @Default('') String search,
    String? memberId,
    FineStatus? status,
    @Default(false) bool outstandingOnly,
    @Default('raisedAt') String sortColumn,
    @Default(false) bool sortAscending,
    @Default(0) int offset,
    @Default(50) int limit,
  }) = _FineQuery;
}

typedef FineListResult = ({List<Fine> items, int totalCount});
