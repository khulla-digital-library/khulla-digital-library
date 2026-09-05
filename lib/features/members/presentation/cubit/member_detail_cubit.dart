import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine_query.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/features/members/domain/member_repository.dart';
import 'package:khulla/features/members/presentation/cubit/member_detail_state.dart';
import 'package:khulla/shared/models/load_status.dart';

/// A single member with open loans, history and outstanding fines.
///
/// Page-scoped `@injectable` cubit for the member detail page. Reads from
/// [MemberRepository] and [CirculationRepository] emit into state; [removeMember]
/// rethrows so the confirming dialog can toast.
@injectable
class MemberDetailCubit extends Cubit<MemberDetailState> {
  MemberDetailCubit(this._members, this._circulation)
    : super(const MemberDetailState());

  final MemberRepository _members;
  final CirculationRepository _circulation;

  /// Loads the member, open loans, returned loans and unpaid fines.
  Future<void> loadMember(String id) async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final member = await _members.findMember(id);
      if (isClosed) return;
      if (member == null) {
        emit(
          state.copyWith(
            status: LoadStatus.failure,
            error: const NotFoundException('Member not found.'),
          ),
        );
        return;
      }
      final openResult = await _circulation.findOpenLoans(
        LoanQuery(memberId: id, openOnly: true, limit: 100),
      );
      if (isClosed) return;
      final historyResult = await _circulation.findLoans(
        LoanQuery(memberId: id, limit: 100),
      );
      if (isClosed) return;
      final finesResult = await _circulation.findFines(
        FineQuery(memberId: id, outstandingOnly: true, limit: 100),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          member: member,
          openLoans: openResult.items,
          historyLoans: [
            for (final loan in historyResult.items)
              if (loan.returnedAt != null) loan,
          ],
          fines: finesResult.items,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  /// Deletes the member. Rethrows on failure — the confirming dialog toasts.
  Future<void> removeMember(String id) async {
    await _members.removeMember(id);
  }
}
