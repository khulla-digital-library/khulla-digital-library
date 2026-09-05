import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';

part 'loan_query.freezed.dart';

/// Filters and paging for loan lists.
///
/// [openOnly] hides returned rows; [status] applies the derived desk status.
@freezed
abstract class LoanQuery with _$LoanQuery {
  const factory LoanQuery({
    @Default('') String search,
    String? memberId,
    String? copyId,
    String? titleId,
    LoanStatus? status,
    @Default(false) bool openOnly,
    @Default('checkedOutAt') String sortColumn,
    @Default(false) bool sortAscending,
    @Default(0) int offset,
    @Default(50) int limit,
  }) = _LoanQuery;
}

typedef LoanListResult = ({List<Loan> items, int totalCount});
