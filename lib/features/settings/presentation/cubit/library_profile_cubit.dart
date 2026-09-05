import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/money/currency.dart';
import 'package:khulla/features/settings/domain/library_settings_repository.dart';
import 'package:khulla/features/settings/presentation/cubit/library_profile_state.dart';
import 'package:khulla/shared/models/load_status.dart';

@injectable
class LibraryProfileCubit extends Cubit<LibraryProfileState> {
  LibraryProfileCubit(this._repository) : super(const LibraryProfileState());

  final LibrarySettingsRepository _repository;

  Future<void> loadProfile() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final profile = await _repository.findProfile();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          profile: profile,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  Future<void> saveProfile({
    required String name,
    required AppCurrency currency,
    String? branch,
    String? email,
    String? phone,
    String? address,
    String? openingHours,
  }) async {
    final existing = state.profile;
    if (existing == null) return;

    emit(state.copyWith(isSaving: true, error: null));
    try {
      final saved = await _repository.saveProfile(
        existing.copyWith(
          name: name.trim(),
          currency: currency,
          branch: _trimOrNull(branch),
          email: _trimOrNull(email),
          phone: _trimOrNull(phone),
          address: _trimOrNull(address),
          openingHours: _trimOrNull(openingHours),
        ),
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          profile: saved,
          isSaving: false,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(isSaving: false, error: error));
      rethrow;
    }
  }

  String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
