import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/copy/domain/copy_repository.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';
import 'package:khulla/features/catalog/title/domain/title_repository.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title_form_state.dart';
import 'package:khulla/shared/domain/reference_data_repository.dart';
import 'package:khulla/shared/models/load_status.dart';

@injectable
class TitleFormCubit extends Cubit<TitleFormState> {
  TitleFormCubit(
    this._titles,
    this._copies,
    this._referenceData,
  ) : super(const TitleFormState());

  final TitleRepository _titles;
  final CopyRepository _copies;
  final ReferenceDataRepository _referenceData;

  Future<void> load({String? titleId}) async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final formats = await _referenceData.findActiveFormats();
      final existing = titleId == null
          ? null
          : await _titles.findTitle(titleId);
      if (isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          existing: existing,
          formats: formats,
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }

  Future<Title> saveTitle({
    required String title,
    required String author,
    required String formatId,
    required bool lendable,
    required String replacementCostText,
    required String language,
    required List<String> subjects,
    required int initialCopies,
    String? subtitle,
    String? isbn,
    String? publisher,
    int? publishedYear,
    String? edition,
    int? pages,
    String? description,
    String? shelf,
  }) async {
    emit(state.copyWith(isSaving: true, error: null));
    try {
      final saved = await _titles.saveTitle(
        id: state.existing?.id,
        title: title,
        author: author,
        formatId: formatId,
        subtitle: subtitle,
        isbn: isbn,
        publisher: publisher,
        publishedYear: publishedYear,
        edition: edition,
        language: language,
        pages: pages,
        subjects: subjects,
        description: description,
        shelf: shelf,
        lendable: lendable,
        replacementCost: replacementCostText.toMoney(),
      );
      if (state.existing == null && initialCopies > 0) {
        for (var i = 0; i < initialCopies; i++) {
          await _copies.addCopy(
            titleId: saved.id,
            titleName: saved.title,
            shelf: shelf,
          );
        }
      }
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
