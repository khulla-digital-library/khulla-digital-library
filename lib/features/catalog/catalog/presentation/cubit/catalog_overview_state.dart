import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';
import 'package:khulla/shared/models/load_status.dart';

part 'catalog_overview_state.freezed.dart';

/// Catalogue overview headline counts and recent titles.
@freezed
abstract class CatalogOverviewState with _$CatalogOverviewState {
  const factory CatalogOverviewState({
    @Default(LoadStatus.initial) LoadStatus status,
    @Default(0) int titleCount,
    @Default(0) int copyCount,
    @Default(0) int availableCount,
    @Default(0) int authorCount,
    @Default(<Title>[]) List<Title> recentTitles,
    AppException? error,
  }) = _CatalogOverviewState;

  const CatalogOverviewState._();

  bool get isLoading => status.isLoading;
  bool get hasError => status.hasError;
}
