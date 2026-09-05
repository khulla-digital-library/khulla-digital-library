import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/members/domain/member_repository.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/presentation/cubit/member_form_state.dart';
import 'package:khulla/shared/domain/reference_data_repository.dart';
import 'package:khulla/shared/models/load_status.dart';

@injectable
class MemberFormCubit extends Cubit<MemberFormState> {
  MemberFormCubit(this._members, this._referenceData)
    : super(const MemberFormState());

  final MemberRepository _members;
  final ReferenceDataRepository _referenceData;

  Future<void> load({String? memberId}) async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final memberTypes = await _referenceData.findActiveMemberTypes();
      final existing = memberId == null
          ? null
          : await _members.findMember(memberId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          existing: existing,
          memberTypes: memberTypes,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  Future<Member> saveMember({
    required String fullName,
    required String cardNumber,
    required String memberTypeId,
    required bool sendNotices,
    String? email,
    String? phone,
    String? address,
    String? dateOfBirthText,
    String? guardian,
    String? notes,
  }) async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      final saved = await _members.saveMember(
        id: state.existing?.id,
        fullName: fullName,
        cardNumber: cardNumber,
        memberTypeId: memberTypeId,
        sendNotices: sendNotices,
        email: email,
        phone: phone,
        address: address,
        guardian: guardian,
        notes: notes,
      );
      if (isClosed) return saved;
      emit(state.copyWith(isSaving: false, existing: saved));
      return saved;
    } on AppException catch (error) {
      if (isClosed) rethrow;
      emit(state.copyWith(isSaving: false, error: error));
      rethrow;
    }
  }
}
