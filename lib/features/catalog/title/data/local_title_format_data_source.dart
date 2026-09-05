import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/features/catalog/title/data/mappers/title_format_row_mappers.dart';
import 'package:khulla/features/catalog/title/data/title_format_local_data_source.dart';
import 'package:khulla/features/catalog/title/domain/models/title_format.dart';

@LazySingleton(as: TitleFormatLocalDataSource)
class LocalTitleFormatDataSource implements TitleFormatLocalDataSource {
  LocalTitleFormatDataSource(this._db);

  final AppDatabase _db;

  static const String _source = 'LocalTitleFormatDataSource';

  @override
  Future<int> countFormats() => guardDatabase(
    () {
      final count = _db.titleFormats.id.count();
      return (_db.selectOnly(
        _db.titleFormats,
      )..addColumns([count])).getSingle().then((row) => row.read(count) ?? 0);
    },
    source: '$_source.countFormats',
  );

  @override
  Future<List<TitleFormat>> findActiveFormats() => guardDatabase(
    () async {
      final rows =
          await (_db.select(_db.titleFormats)
                ..where((format) => format.archivedAt.isNull())
                ..orderBy([
                  (format) => OrderingTerm(expression: format.sortOrder),
                ]))
              .get();
      return rows.map((row) => row.toDomain()).toList();
    },
    source: '$_source.findActiveFormats',
  );

  @override
  Future<TitleFormat> insertFormat(TitleFormat format) => guardDatabase(
    () async {
      await _db.into(_db.titleFormats).insert(format.toCompanion());
      return format;
    },
    source: '$_source.insertFormat',
  );
}
