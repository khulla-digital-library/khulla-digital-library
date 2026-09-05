import 'package:khulla/features/catalog/title/domain/models/title.dart';
import 'package:khulla/features/catalog/title/domain/models/title_query.dart';

abstract interface class TitleLocalDataSource {
  Future<TitleListResult> findTitles(TitleQuery query);

  Future<Title?> findTitleById(String id);

  Future<Title> insertTitle(Title title, {required String searchText});

  Future<Title> updateTitle(Title title, {required String searchText});

  Future<void> archiveTitle(String id, DateTime archivedAt);

  Future<bool> hasDependentCopies(String titleId);

  Future<void> deleteTitle(String id);
}
