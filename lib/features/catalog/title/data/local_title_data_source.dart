import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/title/data/mappers/title_row_mappers.dart';
import 'package:khulla/features/catalog/title/data/title_local_data_source.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';
import 'package:khulla/features/catalog/title/domain/models/title_query.dart';

/// Drift-backed [TitleLocalDataSource].
///
/// List and detail queries use custom SQL so copy and availability counts arrive
/// in one round trip. Sort column names match [TitleQuery.sortColumn].
@LazySingleton(as: TitleLocalDataSource)
class LocalTitleDataSource implements TitleLocalDataSource {
  LocalTitleDataSource(this._db);

  final AppDatabase _db;

  static const String _source = 'LocalTitleDataSource';

  @override
  Future<TitleListResult> findTitles(TitleQuery query) => guardDatabase(
    () async {
      final needle = query.search.trim().toLowerCase();
      final where = StringBuffer('t.archived_at IS NULL');
      final variables = <Variable<Object>>[];

      if (needle.isNotEmpty) {
        where.write(' AND t.search_text LIKE ?');
        variables.add(Variable<String>('%$needle%'));
      }
      if (query.formatId != null) {
        where.write(' AND t.format_id = ?');
        variables.add(Variable<String>(query.formatId));
      }

      final having = query.availableOnly ? ' HAVING available_count > 0' : '';

      final order = _orderClause(query);

      final countSql =
          '''
SELECT COUNT(*) AS total FROM (
  SELECT t.id,
         COUNT(CASE WHEN c.status = 'available' AND c.archived_at IS NULL THEN 1 END) AS available_count
  FROM titles t
  LEFT JOIN copies c ON c.title_id = t.id AND c.archived_at IS NULL
  WHERE $where
  GROUP BY t.id$having
)''';

      final listSql =
          '''
SELECT t.*,
       f.name AS format_name,
       f.code AS format_code,
       COUNT(c.id) AS copy_count,
       COUNT(CASE WHEN c.status = 'available' THEN 1 END) AS available_count
FROM titles t
JOIN title_formats f ON f.id = t.format_id
LEFT JOIN copies c ON c.title_id = t.id AND c.archived_at IS NULL
WHERE $where
GROUP BY t.id
$having
ORDER BY $order
LIMIT ? OFFSET ?''';

      final countRow = await _db
          .customSelect(countSql, variables: variables)
          .getSingle();
      final totalCount = countRow.read<int>('total');

      final listVariables = [
        ...variables,
        Variable<int>(query.limit),
        Variable<int>(query.offset),
      ];
      final rows = await _db
          .customSelect(listSql, variables: listVariables)
          .get();

      final items = rows.map(_mapRow).toList();
      return (items: items, totalCount: totalCount);
    },
    source: '$_source.findTitles',
  );

  String _orderClause(TitleQuery query) {
    final dir = query.sortAscending ? 'ASC' : 'DESC';
    return switch (query.sortColumn) {
      'author' => 't.author $dir',
      'publisher' => 't.publisher $dir',
      'year' => 't.published_year $dir',
      'copies' => 'copy_count $dir',
      'available' => 'available_count $dir',
      'title' => 't.title $dir',
      _ => 't.created_at $dir',
    };
  }

  Title _mapRow(QueryRow row) => Title(
    id: row.read<String>('id'),
    title: row.read<String>('title'),
    author: row.read<String>('author'),
    isbn: row.readNullable<String>('isbn'),
    publisher: row.readNullable<String>('publisher'),
    publishedYear: row.readNullable<int>('published_year'),
    edition: row.readNullable<String>('edition'),
    language: row.read<String>('language'),
    pages: row.readNullable<int>('pages'),
    description: row.readNullable<String>('description'),
    shelf: row.readNullable<String>('shelf'),
    formatId: row.read<String>('format_id'),
    formatName: row.read<String>('format_name'),
    formatCode: row.readNullable<String>('format_code'),
    lendable: row.read<bool>('lendable'),
    replacementCost: Money(row.read<int>('replacement_cost')),
    createdAt: row.read<DateTime>('created_at'),
    updatedAt: row.read<DateTime>('updated_at'),
    archivedAt: row.readNullable<DateTime>('archived_at'),
    copyCount: row.read<int>('copy_count'),
    availableCount: row.read<int>('available_count'),
  );

  @override
  Future<Title?> findTitleById(String id) => guardDatabase(
    () async {
      final rows = await _db
          .customSelect(
            '''
SELECT t.*,
       f.name AS format_name,
       f.code AS format_code,
       COUNT(c.id) AS copy_count,
       COUNT(CASE WHEN c.status = 'available' THEN 1 END) AS available_count
FROM titles t
JOIN title_formats f ON f.id = t.format_id
LEFT JOIN copies c ON c.title_id = t.id AND c.archived_at IS NULL
WHERE t.id = ?
GROUP BY t.id
''',
            variables: [Variable<String>(id)],
          )
          .get();
      if (rows.isEmpty) return null;
      return _mapRow(rows.first);
    },
    source: '$_source.findTitleById',
  );

  @override
  Future<Title> insertTitle(Title title, {required String searchText}) =>
      guardDatabase(
        () async {
          await _db
              .into(_db.titles)
              .insert(
                title.toCompanion(searchText: searchText),
              );
          return (await findTitleById(title.id))!;
        },
        source: '$_source.insertTitle',
      );

  @override
  Future<Title> updateTitle(Title title, {required String searchText}) =>
      guardDatabase(
        () async {
          await (_db.update(_db.titles)..where((t) => t.id.equals(title.id)))
              .write(title.toCompanion(searchText: searchText));
          return (await findTitleById(title.id))!;
        },
        source: '$_source.updateTitle',
      );

  @override
  Future<void> archiveTitle(String id, DateTime archivedAt) => guardDatabase(
    () async {
      await (_db.update(_db.titles)..where((t) => t.id.equals(id))).write(
        TitlesCompanion(
          archivedAt: Value(archivedAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    },
    source: '$_source.archiveTitle',
  );

  @override
  Future<bool> hasDependentCopies(String titleId) => guardDatabase(
    () async {
      final count = _db.copies.id.count();
      final row =
          await (_db.selectOnly(_db.copies)
                ..addColumns([count])
                ..where(_db.copies.titleId.equals(titleId)))
              .getSingle();
      return (row.read(count) ?? 0) > 0;
    },
    source: '$_source.hasDependentCopies',
  );

  @override
  Future<void> deleteTitle(String id) => guardDatabase(
    () async {
      await (_db.delete(_db.titles)..where((t) => t.id.equals(id))).go();
    },
    source: '$_source.deleteTitle',
  );
}
