import 'package:drift/drift.dart';
import 'package:khulla/core/database/converters/date_only_converter.dart';
import 'package:khulla/features/catalog/copy/data/tables/copies.dart';
import 'package:khulla/features/catalog/title/data/tables/titles.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/members/data/tables/members.dart';

/// A hold on a title — any copy can satisfy it.
@DataClassName('ReservationRow')
@TableIndex.sql(
  'CREATE UNIQUE INDEX reservations_one_active_per_member_title '
  'ON reservations (title_id, member_id) WHERE closed_at IS NULL',
)
@TableIndex.sql(
  'CREATE INDEX reservations_queue ON reservations (title_id, placed_at) '
  'WHERE closed_at IS NULL',
)
class Reservations extends Table {
  TextColumn get id => text()();

  TextColumn get titleId =>
      text().references(Titles, #id, onDelete: KeyAction.restrict)();

  TextColumn get memberId =>
      text().references(Members, #id, onDelete: KeyAction.restrict)();

  DateTimeColumn get placedAt => dateTime()();

  TextColumn get status => textEnum<ReservationStatus>()();

  TextColumn get readyCopyId =>
      text().nullable().references(Copies, #id, onDelete: KeyAction.setNull)();

  DateTimeColumn get readyAt => dateTime().nullable()();

  TextColumn get expiresAt =>
      text().nullable().map(const DateOnlyConverter())();

  DateTimeColumn get closedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
