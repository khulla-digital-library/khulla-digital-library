import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_fine.dart';
import 'package:khulla/features/members/data/mappers/member_row_mappers.dart';
import 'package:khulla/features/members/data/member_local_data_source.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_query.dart';

/// Drift-backed [MemberLocalDataSource].
///
/// List and detail queries join member types and subselect open loans and
/// outstanding fines so each [Member] row is desk-ready without N+1 reads.
@LazySingleton(as: MemberLocalDataSource)
class LocalMemberDataSource implements MemberLocalDataSource {
  LocalMemberDataSource(this._db);

  final AppDatabase _db;

  static const String _source = 'LocalMemberDataSource';

  static const String _selectColumns = '''
m.*,
mt.name AS member_type_name,
mt.code AS member_type_code,
COALESCE(loans_agg.loans_out, 0) AS loans_out,
COALESCE(loans_agg.overdue_loans, 0) AS overdue_loans,
COALESCE(fines_agg.fines_owed, 0) AS fines_owed,
COALESCE(loans_agg.borrowed_all_time, 0) AS borrowed_all_time
''';

  static const String _fromClause = '''
FROM members m
JOIN member_types mt ON mt.id = m.member_type_id
LEFT JOIN (
  SELECT member_id,
         COUNT(CASE WHEN returned_at IS NULL THEN 1 END) AS loans_out,
         COUNT(CASE WHEN returned_at IS NULL AND due_at < ? THEN 1 END) AS overdue_loans,
         COUNT(*) AS borrowed_all_time
  FROM loans
  GROUP BY member_id
) loans_agg ON loans_agg.member_id = m.id
LEFT JOIN (
  SELECT member_id,
         SUM(assessed - paid - waived) AS fines_owed
  FROM fines
  WHERE paid + waived < assessed
  GROUP BY member_id
) fines_agg ON fines_agg.member_id = m.id
''';

  @override
  Future<MemberListResult> findMembers(MemberQuery query) => guardDatabase(
    () async {
      final today = dateOnly(DateTime.now());
      final todaySql = _dateToSql(today);
      final expiringEndSql = _dateToSql(addCalendarDays(today, 30));

      final where = StringBuffer('m.archived_at IS NULL');
      final variables = <Variable<Object>>[Variable<String>(todaySql)];

      final needle = query.search.trim().toLowerCase();
      if (needle.isNotEmpty) {
        where.write(' AND m.search_text LIKE ?');
        variables.add(Variable<String>('%$needle%'));
      }
      if (query.withLoans) {
        where.write(' AND COALESCE(loans_agg.loans_out, 0) > 0');
      }
      if (query.owesFines) {
        where.write(' AND COALESCE(fines_agg.fines_owed, 0) > 0');
      }
      if (query.suspended) {
        where.write(' AND m.suspended_at IS NOT NULL');
      }
      if (query.expiring) {
        where.write(
          ' AND m.suspended_at IS NULL'
          ' AND m.expires_at IS NOT NULL'
          ' AND m.expires_at > ?'
          ' AND m.expires_at <= ?',
        );
        variables.addAll([
          Variable<String>(todaySql),
          Variable<String>(expiringEndSql),
        ]);
      }

      final order = _orderClause(query);
      final countSql = 'SELECT COUNT(*) AS total $_fromClause WHERE $where';
      final listSql =
          '''
SELECT $_selectColumns
$_fromClause
WHERE $where
ORDER BY $order
LIMIT ? OFFSET ?
''';

      final totalCount = await _db
          .customSelect(countSql, variables: variables)
          .getSingle()
          .then((row) => row.read<int>('total'));

      final rows = await _db
          .customSelect(
            listSql,
            variables: [
              ...variables,
              Variable<int>(query.limit),
              Variable<int>(query.offset),
            ],
          )
          .get();

      return (
        items: rows.map(_mapRow).toList(),
        totalCount: totalCount,
      );
    },
    source: '$_source.findMembers',
  );

  String _orderClause(MemberQuery query) {
    final dir = query.sortAscending ? 'ASC' : 'DESC';
    return switch (query.sortColumn) {
      'card' => 'm.card_number $dir',
      'loans' => 'loans_out $dir',
      'fines' => 'fines_owed $dir',
      'joined' => 'm.joined_at $dir',
      'expires' => 'm.expires_at $dir',
      'name' => 'm.full_name $dir',
      _ => 'm.created_at $dir',
    };
  }

  Member _mapRow(QueryRow row) => Member(
    id: row.read<String>('id'),
    fullName: row.read<String>('full_name'),
    cardNumber: row.read<String>('card_number'),
    memberTypeId: row.read<String>('member_type_id'),
    memberTypeName: row.read<String>('member_type_name'),
    memberTypeCode: row.readNullable<String>('member_type_code'),
    joinedAt: row.read<DateTime>('joined_at'),
    createdAt: row.read<DateTime>('created_at'),
    updatedAt: row.read<DateTime>('updated_at'),
    loansOut: row.read<int>('loans_out'),
    overdueLoans: row.read<int>('overdue_loans'),
    finesOwed: Money(row.read<int>('fines_owed')),
    borrowedAllTime: row.read<int>('borrowed_all_time'),
    sendNotices: row.read<bool>('send_notices'),
    dateOfBirth: row.readNullable<DateTime>('date_of_birth'),
    email: row.readNullable<String>('email'),
    phone: row.readNullable<String>('phone'),
    address: row.readNullable<String>('address'),
    guardian: row.readNullable<String>('guardian'),
    notes: row.readNullable<String>('notes'),
    expiresAt: row.readNullable<DateTime>('expires_at'),
    suspendedAt: row.readNullable<DateTime>('suspended_at'),
    suspensionReason: row.readNullable<String>('suspension_reason'),
    archivedAt: row.readNullable<DateTime>('archived_at'),
  );

  String _dateToSql(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  @override
  Future<Member?> findMemberByCardNumber(String cardNumber) => guardDatabase(
    () async {
      final trimmed = cardNumber.trim();
      if (trimmed.isEmpty) return null;

      final today = dateOnly(DateTime.now());
      final rows = await _db
          .customSelect(
            '''
SELECT $_selectColumns
$_fromClause
WHERE m.archived_at IS NULL
  AND LOWER(m.card_number) = LOWER(?)
''',
            variables: [
              Variable<String>(_dateToSql(today)),
              Variable<String>(trimmed),
            ],
          )
          .get();
      if (rows.isEmpty) return null;
      return _mapRow(rows.first);
    },
    source: '$_source.findMemberByCardNumber',
  );

  @override
  Future<Member?> findMemberById(String id) => guardDatabase(
    () async {
      final today = dateOnly(DateTime.now());
      final rows = await _db
          .customSelect(
            '''
SELECT $_selectColumns
$_fromClause
WHERE m.id = ?
''',
            variables: [
              Variable<String>(_dateToSql(today)),
              Variable<String>(id),
            ],
          )
          .get();
      if (rows.isEmpty) return null;
      return _mapRow(rows.first);
    },
    source: '$_source.findMemberById',
  );

  @override
  Future<Member> insertMember(Member member, {required String searchText}) =>
      guardDatabase(
        () async {
          await _db
              .into(_db.members)
              .insert(
                member.toCompanion(searchText: searchText),
              );
          return (await findMemberById(member.id))!;
        },
        source: '$_source.insertMember',
      );

  @override
  Future<Member> updateMember(Member member, {required String searchText}) =>
      guardDatabase(
        () async {
          await (_db.update(_db.members)..where((m) => m.id.equals(member.id)))
              .write(member.toCompanion(searchText: searchText));
          return (await findMemberById(member.id))!;
        },
        source: '$_source.updateMember',
      );

  @override
  Future<void> archiveMember(String id, DateTime archivedAt) => guardDatabase(
    () async {
      await (_db.update(_db.members)..where((m) => m.id.equals(id))).write(
        MembersCompanion(
          archivedAt: Value(archivedAt),
          updatedAt: Value(DateTime.now()),
        ),
      );
    },
    source: '$_source.archiveMember',
  );

  @override
  Future<bool> hasCirculationHistory(String memberId) => guardDatabase(
    () async {
      final count = _db.loans.id.count();
      final row =
          await (_db.selectOnly(_db.loans)
                ..addColumns([count])
                ..where(_db.loans.memberId.equals(memberId)))
              .getSingle();
      return (row.read(count) ?? 0) > 0;
    },
    source: '$_source.hasCirculationHistory',
  );

  @override
  Future<void> deleteMember(String id) => guardDatabase(
    () async {
      await (_db.delete(_db.members)..where((m) => m.id.equals(id))).go();
    },
    source: '$_source.deleteMember',
  );
}
