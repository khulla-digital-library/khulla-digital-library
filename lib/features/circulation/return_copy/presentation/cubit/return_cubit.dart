import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';
import 'package:khulla/features/circulation/return_copy/presentation/cubit/return_state.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';

@injectable
class ReturnCubit extends Cubit<ReturnState> {
  ReturnCubit(this._repository) : super(const ReturnState());

  final CirculationRepository _repository;

  Future<void> addLoanByBarcode(String barcode) async {
    final trimmed = barcode.trim();
    if (trimmed.isEmpty) return;

    try {
      final result = await _repository.findOpenLoans(
        LoanQuery(search: trimmed, limit: 5),
      );
      if (isClosed) return;

      Loan? loan;
      for (final item in result.items) {
        if (item.barcode?.toLowerCase() == trimmed.toLowerCase()) {
          loan = item;
          break;
        }
      }
      loan ??= result.items.length == 1 ? result.items.first : null;
      if (loan == null) {
        throw const NotFoundException('That copy is not on loan.');
      }
      final resolved = loan;
      if (state.basket.any((item) => item.id == resolved.id)) {
        throw const ConflictException('That copy is already in the basket.');
      }
      emit(state.copyWith(basket: [...state.basket, resolved], error: null));
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(error: error));
      rethrow;
    }
  }

  void removeLoan(Loan loan) {
    emit(
      state.copyWith(
        basket: state.basket.where((item) => item.id != loan.id).toList(),
        error: null,
      ),
    );
  }

  void waiveFinesChanged(bool value) {
    emit(state.copyWith(waiveFines: value, error: null));
  }

  void conditionChanged(CopyCondition value) {
    emit(state.copyWith(condition: value, error: null));
  }

  Future<void> returnCopies() async {
    if (state.basket.isEmpty) return;

    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _repository.returnCopies(
        copies: [
          for (final loan in state.basket)
            (barcode: loan.barcode ?? '', condition: state.condition),
        ],
        waiveFine: state.waiveFines,
      );
      if (isClosed) return;
      emit(const ReturnState());
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isSubmitting: false, error: error));
      rethrow;
    }
  }
}
