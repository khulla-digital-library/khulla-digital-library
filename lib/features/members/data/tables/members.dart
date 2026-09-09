import 'package:drift/drift.dart';
import 'package:khulla/core/database/converters/date_only_converter.dart';
import 'package:khulla/features/members/data/tables/member_types.dart';

/// One borrower on the register.
@DataClassName('MemberRow')
@TableIndex(name: 'members_card', columns: {#cardNumber}, unique: true)
@TableIndex(name: 'members_search', columns: {#searchText})
@TableIndex(name: 'members_type', columns: {#memberTypeId})
@TableIndex.sql(
  'CREATE INDEX members_expiry ON members (expires_at) WHERE archived_at IS NULL',
)
class Members extends Table {
  TextColumn get id => text()();

  TextColumn get cardNumber => text().unique()();

  TextColumn get fullName => text().withLength(min: 1, max: 160)();

  TextColumn get memberTypeId =>
      text().references(MemberTypes, #id, onDelete: KeyAction.restrict)();

  TextColumn get dateOfBirth =>
      text().nullable().map(const DateOnlyConverter())();

  TextColumn get email => text().nullable()();

  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();

  TextColumn get guardian => text().nullable()();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get joinedAt => dateTime()();

  TextColumn get expiresAt =>
      text().nullable().map(const DateOnlyConverter())();

  DateTimeColumn get suspendedAt => dateTime().nullable()();

  TextColumn get suspensionReason => text().nullable()();

  BoolColumn get sendNotices => boolean().withDefault(const Constant(true))();

  TextColumn get searchText => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get archivedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
