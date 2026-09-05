import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/shared/domain/reference_data_repository.dart';
import 'package:khulla/shared/models/load_status.dart';
import 'package:khulla/shared/presentation/cubit/reference_data_state.dart';

@lazySingleton
class ReferenceDataCubit extends Cubit<ReferenceDataState> {
  ReferenceDataCubit(this._repository) : super(const ReferenceDataState());

  final ReferenceDataRepository _repository;

  Future<void> loadReferenceData() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final formats = await _repository.findActiveFormats();
      final memberTypes = await _repository.findActiveMemberTypes();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          formats: formats,
          memberTypes: memberTypes,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  Future<void> refreshFormats() async {
    final formats = await _repository.findActiveFormats();
    if (isClosed) return;
    emit(state.copyWith(formats: formats));
  }

  Future<void> refreshMemberTypes() async {
    final memberTypes = await _repository.findActiveMemberTypes();
    if (isClosed) return;
    emit(state.copyWith(memberTypes: memberTypes));
  }
}
