import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/circulation/circulation/presentation/cubit/loan_list_state.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';
import 'package:khulla/features/circulation/reservation/domain/models/reservation_query.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';
import 'package:khulla/shared/models/load_status.dart';

/// Open loans list plus circulation headline counts.
///
/// Page-scoped `@injectable` cubit backed by [CirculationRepository].
/// [loadOpenLoans] fetches the filtered list and sidebar totals in one
/// round-trip; failures emit into [LoanListState.error].
@injectable
class LoanListCubit extends Cubit<LoanListState> {
  LoanListCubit(this._repository) : super(const LoanListState());

  final CirculationRepository _repository;

  /// Loads the filtered loan list and on-loan, due-today, overdue and hold counts.
  Future<void> loadOpenLoans() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final results = await Future.wait([
        _repository.findOpenLoans(state.query),
        _repository.findOpenLoans(const LoanQuery()),
        _repository.findOpenLoans(
          const LoanQuery(status: LoanStatus.dueToday),
        ),
        _repository.findOpenLoans(
          const LoanQuery(status: LoanStatus.overdue),
        ),
        _repository.findReservations(const ReservationQuery(limit: 1)),
      ]);
      if (isClosed) return;

      final listResult = results[0] as LoanListResult;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          loans: listResult.items,
          totalCount: listResult.totalCount,
          onLoanCount: (results[1] as LoanListResult).totalCount,
          dueTodayCount: (results[2] as LoanListResult).totalCount,
          overdueCount: (results[3] as LoanListResult).totalCount,
          holdsCount: (results[4] as ReservationListResult).totalCount,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  void searchChanged(String value) {
    emit(
      state.copyWith(
        query: state.query.copyWith(search: value, offset: 0),
      ),
    );
    unawaited(loadOpenLoans());
  }

  void statusFilterChanged(LoanStatus? status) {
    emit(
      state.copyWith(
        query: state.query.copyWith(status: status, offset: 0),
      ),
    );
    unawaited(loadOpenLoans());
  }

  void sortChanged(String columnId, bool ascending) {
    emit(
      state.copyWith(
        query: state.query.copyWith(
          sortColumn: _mapSortColumn(columnId),
          sortAscending: ascending,
          offset: 0,
        ),
      ),
    );
    unawaited(loadOpenLoans());
  }

  void clearFilters() {
    emit(
      state.copyWith(
        query: const LoanQuery(openOnly: true),
      ),
    );
    unawaited(loadOpenLoans());
  }

  String _mapSortColumn(String columnId) => switch (columnId) {
    'member' => 'memberName',
    'title' => 'titleName',
    'issued' => 'checkedOutAt',
    'barcode' => 'barcode',
    _ => 'dueAt',
  };
}
