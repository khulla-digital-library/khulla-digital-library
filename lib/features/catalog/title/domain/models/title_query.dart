import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';

part 'title_query.freezed.dart';

/// Filters and paging for the title list and OPAC-style search.
///
/// [search] matches the denormalized `search_text` column; [availableOnly]
/// hides titles with no copies on shelf.
@freezed
abstract class TitleQuery with _$TitleQuery {
  const factory TitleQuery({
    @Default('') String search,
    String? formatId,
    @Default(false) bool availableOnly,
    @Default('title') String sortColumn,
    @Default(true) bool sortAscending,
    @Default(0) int offset,
    @Default(8) int limit,
  }) = _TitleQuery;
}

typedef TitleListResult = ({List<Title> items, int totalCount});
