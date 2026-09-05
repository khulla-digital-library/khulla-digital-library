import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine_query.dart';
import 'package:khulla/features/circulation/fine/presentation/cubit/fine_list_state.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';
import 'package:khulla/shared/models/load_status.dart';

@injectable
class FineListCubit extends Cubit<FineListState> {
  FineListCubit(this._repository) : super(const FineListState());

  final CirculationRepository _repository;

  Future<void> loadFines() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final results = await Future.wait<FineListResult>([
        _repository.findFines(state.query),
        _repository.findFines(
          const FineQuery(status: FineStatus.unpaid, limit: 500),
        ),
        _repository.findFines(
          const FineQuery(status: FineStatus.paid, limit: 500),
        ),
        _repository.findFines(
          const FineQuery(status: FineStatus.waived, limit: 500),
        ),
      ]);
      if (isClosed) return;

      final listResult = results[0];
      final unpaid = results[1];
      final paid = results[2];
      final waived = results[3];

      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          fines: listResult.items,
          totalCount: listResult.totalCount,
          outstandingTotal: Money.sum([
            for (final fine in unpaid.items) fine.outstanding,
          ]),
          collectedTotal: Money.sum([for (final fine in paid.items) fine.paid]),
          waivedTotal: Money.sum([
            for (final fine in waived.items) fine.waived,
          ]),
          membersOwing: {
            for (final fine in unpaid.items)
              if (fine.outstanding.isPositive) fine.memberId,
          }.length,
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
    unawaited(loadFines());
  }

  void statusFilterChanged(FineStatus? status) {
    emit(
      state.copyWith(
        query: state.query.copyWith(status: status, offset: 0),
      ),
    );
    unawaited(loadFines());
  }

  void clearFilters() {
    emit(state.copyWith(query: const FineQuery()));
    unawaited(loadFines());
  }
}
