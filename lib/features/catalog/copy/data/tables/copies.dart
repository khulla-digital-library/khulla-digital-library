import 'package:drift/drift.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/title/data/tables/titles.dart';

/// One physical item on a shelf — an identifier plus physical state.
@DataClassName('CopyRow')
@TableIndex(name: 'copies_barcode', columns: {#barcode}, unique: true)
@TableIndex.sql(
  'CREATE INDEX copies_status ON copies (status) WHERE archived_at IS NULL',
)
@TableIndex(name: 'copies_title', columns: {#titleId})
class Copies extends Table {
  TextColumn get id => text()();

  TextColumn get titleId =>
      text().references(Titles, #id, onDelete: KeyAction.restrict)();

  TextColumn get barcode => text().unique()();

  /// When null, inherits the title's shelf location.
  TextColumn get shelf => text().nullable().withLength(max: 60)();

  TextColumn get condition => textEnum<CopyCondition>()();

  TextColumn get status => textEnum<CopyStatus>()();

  DateTimeColumn get acquiredAt => dateTime()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
