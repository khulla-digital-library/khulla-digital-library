import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/copy/domain/copy_repository.dart';
import 'package:khulla/features/catalog/title/domain/title_repository.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title_detail_state.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/shared/models/load_status.dart';

/// A single title record plus its copies and loan history.
///
/// Page-scoped `@injectable` cubit for the title detail page. Pulls the title
/// from [TitleRepository], copies from [CopyRepository], and returned loans
/// from [CirculationRepository]. Reads emit into state; writes ([removeTitle],
/// [addCopy]) rethrow so the gesture can toast.
@injectable
class TitleDetailCubit extends Cubit<TitleDetailState> {
  TitleDetailCubit(this._titles, this._copies, this._circulation)
    : super(const TitleDetailState());

  final TitleRepository _titles;
  final CopyRepository _copies;
  final CirculationRepository _circulation;

  /// Loads the title, its copies, and returned loans for [id].
  ///
  /// A missing title becomes a [NotFoundException] in state. Other read
  /// failures are emitted and swallowed.
  Future<void> loadTitle(String id) async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final title = await _titles.findTitle(id);
      if (isClosed) return;
      if (title == null) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            error: const NotFoundException('Title not found.'),
          ),
        );
        return;
      }
      final copies = await _copies.findCopiesByTitleId(id);
      if (isClosed) return;
      final history = await _circulation.findLoans(
        LoanQuery(titleId: id),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          title: title,
          copies: copies,
          historyLoans: [
            for (final loan in history.items)
              if (loan.returnedAt != null) loan,
          ],
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  /// Deletes the title. Rethrows on failure — the confirming dialog toasts.
  Future<void> removeTitle(String id) async {
    await _titles.removeTitle(id);
  }

  /// Adds a copy and reloads the detail pane. Rethrows on failure.
  Future<void> addCopy(
    String titleId,
    String titleName, {
    String? shelf,
  }) async {
    await _copies.addCopy(
      titleId: titleId,
      titleName: titleName,
      shelf: shelf,
    );
    if (isClosed) return;
    await loadTitle(titleId);
  }
}
