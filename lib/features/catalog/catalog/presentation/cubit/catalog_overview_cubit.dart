import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/catalog/presentation/cubit/catalog_overview_state.dart';
import 'package:khulla/features/catalog/copy/domain/copy_repository.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy_query.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/title/domain/models/title_query.dart';
import 'package:khulla/features/catalog/title/domain/title_repository.dart';
import 'package:khulla/shared/models/load_status.dart';

@injectable
class CatalogOverviewCubit extends Cubit<CatalogOverviewState> {
  CatalogOverviewCubit(this._titles, this._copies)
    : super(const CatalogOverviewState());

  final TitleRepository _titles;
  final CopyRepository _copies;

  Future<void> loadOverview() async {
    emit(state.copyWith(status: LoadStatus.loading, error: null));
    try {
      final allTitles = await _titles.findTitles(
        const TitleQuery(limit: 1000),
      );
      if (isClosed) return;
      final allCopies = await _copies.findCopies(const CopyQuery(limit: 1000));
      if (isClosed) return;
      final available = await _copies.findCopies(
        const CopyQuery(
          statuses: {CopyStatus.available},
          limit: 1000,
        ),
      );
      if (isClosed) return;

      final authors = {
        for (final title in allTitles.items) title.author.trim(),
      }.where((name) => name.isNotEmpty).length;

      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          titleCount: allTitles.totalCount,
          copyCount: allCopies.totalCount,
          availableCount: available.totalCount,
          authorCount: authors,
          recentTitles: allTitles.items.take(5).toList(),
          error: null,
        ),
      );
    } on AppException catch (error) {
      if (isClosed) return;
      emit(state.copyWith(status: LoadStatus.failure, error: error));
    }
  }
}
