import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/core/database/converters/date_only_converter.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/error/guard.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/circulation/fine/data/fine_local_data_source.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine_query.dart';
import 'package:khulla/features/circulation/loan/data/loan_local_data_source.dart';
import 'package:khulla/features/circulation/loan/data/mappers/loan_row_mappers.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan.dart';
import 'package:khulla/features/circulation/loan/domain/models/loan_query.dart';
import 'package:khulla/features/circulation/reservation/data/reservation_local_data_source.dart';
import 'package:khulla/features/circulation/reservation/domain/models/reservation.dart';
import 'package:khulla/features/circulation/reservation/domain/models/reservation_query.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_fine.dart';
import 'package:khulla/features/circulation/shared/domain/circulation_repository.dart';
import 'package:khulla/features/circulation/shared/domain/fine_reason.dart';
import 'package:khulla/features/circulation/shared/domain/models/effective_loan_rules.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/circulation/shared/domain/resolve_loan_rules.dart';
import 'package:khulla/features/members/data/mappers/member_type_row_mappers.dart';
import 'package:khulla/features/settings/data/mappers/loan_rules_row_mappers.dart';
import 'package:khulla/features/settings/data/tables/loan_rules.dart';
import 'package:uuid/uuid.dart';

@LazySingleton(as: CirculationRepository)
class CirculationRepositoryImpl implements CirculationRepository {
  CirculationRepositoryImpl(
    this._db,
    this._loanDataSource,
    this._fineDataSource,
    this._reservationDataSource,
  );

  final AppDatabase _db;
  final LoanLocalDataSource _loanDataSource;
  final FineLocalDataSource _fineDataSource;
  final ReservationLocalDataSource _reservationDataSource;

  static const Uuid _uuid = Uuid();
  static const DateOnlyConverter _dates = DateOnlyConverter();
  static const String _source = 'CirculationRepositoryImpl';

  @override
  Future<Loan> checkOutCopy({
    required String memberId,
    required String barcode,
    String? staffId,
  }) => guardDatabase(
    () => _db.transaction(
      () => _checkOutCopy(
        memberId: memberId,
        barcode: barcode.trim(),
        staffId: staffId,
      ),
    ),
    source: '$_source.checkOutCopy',
  );

  Future<Loan> _checkOutCopy({
    required String memberId,
    required String barcode,
    String? staffId,
  }) async {
    final now = DateTime.now();
    final today = dateOnly(now);

    final copyRow = await (_db.select(
      _db.copies,
    )..where((copy) => copy.barcode.equals(barcode))).getSingleOrNull();
    if (copyRow == null) {
      throw const NotFoundException('No copy matches that barcode.');
    }

    final titleRow = await (_db.select(
      _db.titles,
    )..where((title) => title.id.equals(copyRow.titleId))).getSingleOrNull();
    if (titleRow == null) {
      throw const NotFoundException('The title for that copy was not found.');
    }

    final memberRow = await (_db.select(
      _db.members,
    )..where((member) => member.id.equals(memberId))).getSingleOrNull();
    if (memberRow == null) {
      throw const NotFoundException('That member was not found.');
    }

    final rules = await _loadEffectiveRules(memberRow.memberTypeId);

    _rejectArchivedMember(memberRow.archivedAt);
    _rejectSuspendedMember(memberRow.suspendedAt);
    _rejectExpiredMember(memberRow.expiresAt, today);

    if (copyRow.archivedAt != null) {
      throw const ConflictException('That copy has been archived.');
    }
    if (!titleRow.lendable) {
      throw const ConflictException('That title is not lendable.');
    }
    if (titleRow.archivedAt != null) {
      throw const ConflictException('That title has been archived.');
    }

    if (copyRow.status == CopyStatus.reserved) {
      final readyHold =
          await (_db.select(_db.reservations)..where(
                (hold) =>
                    hold.readyCopyId.equals(copyRow.id) &
                    hold.closedAt.isNull() &
                    hold.status.equalsValue(ReservationStatus.ready),
              ))
              .getSingleOrNull();
      if (readyHold == null || readyHold.memberId != memberId) {
        throw const ConflictException(
          'That copy is reserved for another member.',
        );
      }
    } else if (copyRow.status != CopyStatus.available) {
      throw const ConflictException('That copy is not available to borrow.');
    }

    final openLoans = await _countOpenLoans(memberId);
    if (openLoans >= rules.borrowingLimit) {
      throw const ConflictException(
        'That member has reached their borrowing limit.',
      );
    }

    if (rules.blockOverdueBorrowers && await _memberHasOverdueLoans(memberId)) {
      throw const ConflictException(
        'That member has overdue loans and cannot borrow.',
      );
    }

    if (rules.maxOutstandingFine != null) {
      final owed = await _outstandingFines(memberId);
      if (owed > rules.maxOutstandingFine!) {
        throw const ConflictException(
          'That member owes more than the allowed outstanding fine.',
        );
      }
    }

    final firstWaiting =
        await (_db.select(_db.reservations)
              ..where(
                (hold) =>
                    hold.titleId.equals(copyRow.titleId) &
                    hold.closedAt.isNull() &
                    hold.status.equalsValue(ReservationStatus.waiting),
              )
              ..orderBy([(hold) => OrderingTerm(expression: hold.placedAt)]))
            .getSingleOrNull();
    if (firstWaiting != null && firstWaiting.memberId != memberId) {
      throw const ConflictException(
        'Another member has an earlier hold on this title.',
      );
    }

    final loanId = _uuid.v4();
    final dueAt = addCalendarDays(today, rules.loanPeriodDays);

    await _db
        .into(_db.loans)
        .insert(
          LoansCompanion.insert(
            id: loanId,
            copyId: copyRow.id,
            memberId: memberId,
            checkedOutAt: now,
            dueAt: dueAt,
            ruleLoanPeriodDays: rules.loanPeriodDays,
            ruleFinePerDay: rules.finePerDay,
            ruleGraceDays: rules.graceDays,
            ruleMaximumFine: rules.maximumFinePerCopy,
            createdAt: now,
            checkedOutByStaffId: Value(staffId),
          ),
        );

    await (_db.update(
      _db.copies,
    )..where((copy) => copy.id.equals(copyRow.id))).write(
      CopiesCompanion(
        status: const Value(CopyStatus.onLoan),
        updatedAt: Value(now),
      ),
    );

    final memberHold =
        await (_db.select(_db.reservations)..where(
              (hold) =>
                  hold.titleId.equals(copyRow.titleId) &
                  hold.memberId.equals(memberId) &
                  hold.closedAt.isNull(),
            ))
            .getSingleOrNull();
    if (memberHold != null) {
      await (_db.update(
        _db.reservations,
      )..where((hold) => hold.id.equals(memberHold.id))).write(
        ReservationsCompanion(
          status: const Value(ReservationStatus.fulfilled),
          closedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    return (await _loadLoanById(loanId))!;
  }

  @override
  Future<Loan> returnCopy({
    required String barcode,
    required CopyCondition condition,
    bool waiveFine = false,
    String? staffId,
  }) => guardDatabase(
    () => _db.transaction(
      () => _returnCopy(
        barcode: barcode.trim(),
        condition: condition,
        waiveFine: waiveFine,
        staffId: staffId,
      ),
    ),
    source: '$_source.returnCopy',
  );

  @override
  Future<List<Loan>> returnCopies({
    required List<ReturnCopyInput> copies,
    bool waiveFine = false,
    String? staffId,
  }) => guardDatabase(
    () => _db.transaction(() async {
      final closed = <Loan>[];
      for (final item in copies) {
        closed.add(
          await _returnCopy(
            barcode: item.barcode.trim(),
            condition: item.condition,
            waiveFine: waiveFine,
            staffId: staffId,
          ),
        );
      }
      return closed;
    }),
    source: '$_source.returnCopies',
  );

  Future<Loan> _returnCopy({
    required String barcode,
    required CopyCondition condition,
    required bool waiveFine,
    String? staffId,
  }) async {
    final now = DateTime.now();
    final today = dateOnly(now);

    final copyRow = await (_db.select(
      _db.copies,
    )..where((copy) => copy.barcode.equals(barcode))).getSingleOrNull();
    if (copyRow == null) {
      throw const NotFoundException('No copy matches that barcode.');
    }

    final loanRow =
        await (_db.select(_db.loans)..where(
              (loan) =>
                  loan.copyId.equals(copyRow.id) & loan.returnedAt.isNull(),
            ))
            .getSingleOrNull();
    if (loanRow == null) {
      throw const NotFoundException('That copy is not on loan.');
    }

    await (_db.update(
      _db.loans,
    )..where((loan) => loan.id.equals(loanRow.id))).write(
      LoansCompanion(
        returnedAt: Value(now),
        returnCondition: Value(condition),
        returnedByStaffId: Value(staffId),
      ),
    );

    final fineAmount = computeOverdueFine(
      dueAt: loanRow.dueAt,
      asOf: today,
      finePerDay: loanRow.ruleFinePerDay,
      graceDays: loanRow.ruleGraceDays,
      maximumFine: loanRow.ruleMaximumFine,
    );

    if (fineAmount.isPositive && !waiveFine) {
      await _db
          .into(_db.fines)
          .insert(
            FinesCompanion.insert(
              id: _uuid.v4(),
              memberId: loanRow.memberId,
              loanId: Value(loanRow.id),
              reason: FineReason.overdue,
              assessed: fineAmount,
              raisedAt: now,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }

    await _promoteHoldOrReleaseCopy(
      copyId: copyRow.id,
      titleId: copyRow.titleId,
      now: now,
      today: today,
      condition: condition,
    );

    return (await _loadLoanById(loanRow.id))!;
  }

  @override
  Future<Loan> renewLoan(String loanId, {String? staffId}) => guardDatabase(
    () => _db.transaction(() => _renewLoan(loanId: loanId)),
    source: '$_source.renewLoan',
  );

  Future<Loan> _renewLoan({required String loanId}) async {
    final loanRow = await (_db.select(
      _db.loans,
    )..where((loan) => loan.id.equals(loanId))).getSingleOrNull();
    if (loanRow == null) {
      throw const NotFoundException('That loan was not found.');
    }
    if (loanRow.returnedAt != null) {
      throw const ConflictException('That loan has already been returned.');
    }

    final copyRow = await (_db.select(
      _db.copies,
    )..where((copy) => copy.id.equals(loanRow.copyId))).getSingleOrNull();
    if (copyRow == null) {
      throw const NotFoundException('The copy for that loan was not found.');
    }

    final rules = await _loadEffectiveRulesForMember(loanRow.memberId);

    if (loanRow.renewalCount >= rules.renewalLimit) {
      throw const ConflictException('That loan has reached its renewal limit.');
    }

    final waitingHolds = await _countWaitingHolds(copyRow.titleId);
    if (waitingHolds > 0) {
      throw const ConflictException(
        'A hold is waiting on this title and the loan cannot be renewed.',
      );
    }

    final extendBy = rules.renewalPeriodDays ?? rules.loanPeriodDays;
    final newDueAt = addCalendarDays(loanRow.dueAt, extendBy);

    await (_db.update(
      _db.loans,
    )..where((loan) => loan.id.equals(loanId))).write(
      LoansCompanion(
        dueAt: Value(newDueAt),
        renewalCount: Value(loanRow.renewalCount + 1),
      ),
    );

    return (await _loadLoanById(loanId))!;
  }

  @override
  Future<Reservation> placeHold({
    required String memberId,
    required String titleId,
  }) => guardDatabase(
    () => _db.transaction(
      () => _placeHold(memberId: memberId, titleId: titleId),
    ),
    source: '$_source.placeHold',
  );

  Future<Reservation> _placeHold({
    required String memberId,
    required String titleId,
  }) async {
    final now = DateTime.now();
    final today = dateOnly(now);

    final memberRow = await (_db.select(
      _db.members,
    )..where((member) => member.id.equals(memberId))).getSingleOrNull();
    if (memberRow == null) {
      throw const NotFoundException('That member was not found.');
    }

    final titleRow = await (_db.select(
      _db.titles,
    )..where((title) => title.id.equals(titleId))).getSingleOrNull();
    if (titleRow == null) {
      throw const NotFoundException('That title was not found.');
    }

    final rules = await _loadEffectiveRules(memberRow.memberTypeId);

    _rejectArchivedMember(memberRow.archivedAt);
    _rejectSuspendedMember(memberRow.suspendedAt);
    _rejectExpiredMember(memberRow.expiresAt, today);

    if (titleRow.archivedAt != null) {
      throw const ConflictException('That title has been archived.');
    }
    if (!titleRow.lendable) {
      throw const ConflictException('That title is not lendable.');
    }

    final activeHolds = await _countActiveHolds(memberId);
    if (activeHolds >= rules.reservationLimit) {
      throw const ConflictException(
        'That member has reached their hold limit.',
      );
    }

    final reservationId = _uuid.v4();
    await _db
        .into(_db.reservations)
        .insert(
          ReservationsCompanion.insert(
            id: reservationId,
            titleId: titleId,
            memberId: memberId,
            placedAt: now,
            status: ReservationStatus.waiting,
            createdAt: now,
            updatedAt: now,
          ),
        );

    return (await _loadReservationById(reservationId))!;
  }

  Future<Reservation?> _loadReservationById(String id) async {
    final row = await (_db.select(
      _db.reservations,
    )..where((hold) => hold.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final title = await (_db.select(
      _db.titles,
    )..where((item) => item.id.equals(row.titleId))).getSingleOrNull();
    final member = await (_db.select(
      _db.members,
    )..where((item) => item.id.equals(row.memberId))).getSingleOrNull();
    final queuePosition = await _queuePosition(row);

    return Reservation(
      id: row.id,
      titleId: row.titleId,
      memberId: row.memberId,
      placedAt: row.placedAt,
      status: row.status,
      readyCopyId: row.readyCopyId,
      readyAt: row.readyAt,
      expiresAt: row.expiresAt,
      closedAt: row.closedAt,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      titleName: title?.title,
      memberName: member?.fullName,
      queuePosition: queuePosition,
    );
  }

  Future<int> _queuePosition(ReservationRow row) async {
    if (row.closedAt != null) return 0;
    final count = _db.reservations.id.count(
      filter:
          _db.reservations.titleId.equals(row.titleId) &
          _db.reservations.closedAt.isNull() &
          _db.reservations.placedAt.isSmallerThanValue(row.placedAt),
    );
    final result = await (_db.selectOnly(
      _db.reservations,
    )..addColumns([count])).getSingle();
    return (result.read(count) ?? 0) + 1;
  }

  @override
  Future<void> cancelHold(String reservationId) => guardDatabase(
    () => _db.transaction(() => _cancelHold(reservationId)),
    source: '$_source.cancelHold',
  );

  Future<void> _cancelHold(String reservationId) async {
    final now = DateTime.now();
    final hold =
        await (_db.select(_db.reservations)..where(
              (row) => row.id.equals(reservationId) & row.closedAt.isNull(),
            ))
            .getSingleOrNull();
    if (hold == null) {
      throw const NotFoundException('That hold was not found.');
    }

    await (_db.update(
      _db.reservations,
    )..where((row) => row.id.equals(reservationId))).write(
      ReservationsCompanion(
        status: const Value(ReservationStatus.cancelled),
        closedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (hold.readyCopyId != null) {
      await (_db.update(
        _db.copies,
      )..where((copy) => copy.id.equals(hold.readyCopyId!))).write(
        CopiesCompanion(
          status: const Value(CopyStatus.available),
          updatedAt: Value(now),
        ),
      );
      await _promoteNextWaitingHold(
        titleId: hold.titleId,
        copyId: hold.readyCopyId!,
        now: now,
        today: dateOnly(now),
      );
    }
  }

  @override
  Future<void> expireStaleHolds() => guardDatabase(
    () => _db.transaction(_expireStaleHolds),
    source: '$_source.expireStaleHolds',
  );

  Future<void> _expireStaleHolds() async {
    final now = DateTime.now();
    final today = dateOnly(now);

    final stale =
        await (_db.select(_db.reservations)..where(
              (hold) =>
                  hold.closedAt.isNull() &
                  hold.status.equalsValue(ReservationStatus.ready) &
                  hold.expiresAt.isSmallerThanValue(_dates.toSql(today)),
            ))
            .get();

    for (final hold in stale) {
      await (_db.update(
        _db.reservations,
      )..where((row) => row.id.equals(hold.id))).write(
        ReservationsCompanion(
          status: const Value(ReservationStatus.expired),
          closedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      if (hold.readyCopyId != null) {
        await (_db.update(
          _db.copies,
        )..where((copy) => copy.id.equals(hold.readyCopyId!))).write(
          CopiesCompanion(
            status: const Value(CopyStatus.available),
            updatedAt: Value(now),
          ),
        );
        await _promoteNextWaitingHold(
          titleId: hold.titleId,
          copyId: hold.readyCopyId!,
          now: now,
          today: today,
        );
      }
    }
  }

  Future<void> _promoteHoldOrReleaseCopy({
    required String copyId,
    required String titleId,
    required DateTime now,
    required DateTime today,
    required CopyCondition condition,
  }) async {
    final nextHold =
        await (_db.select(_db.reservations)
              ..where(
                (hold) =>
                    hold.titleId.equals(titleId) &
                    hold.closedAt.isNull() &
                    hold.status.equalsValue(ReservationStatus.waiting),
              )
              ..orderBy([(hold) => OrderingTerm(expression: hold.placedAt)]))
            .getSingleOrNull();

    if (nextHold != null) {
      final rules = await _loadLoanRules();
      final expiresAt = addCalendarDays(today, rules.holdShelfDays);
      await (_db.update(
        _db.reservations,
      )..where((hold) => hold.id.equals(nextHold.id))).write(
        ReservationsCompanion(
          status: const Value(ReservationStatus.ready),
          readyCopyId: Value(copyId),
          readyAt: Value(now),
          expiresAt: Value(expiresAt),
          updatedAt: Value(now),
        ),
      );
      await (_db.update(
        _db.copies,
      )..where((copy) => copy.id.equals(copyId))).write(
        CopiesCompanion(
          status: const Value(CopyStatus.reserved),
          condition: Value(condition),
          updatedAt: Value(now),
        ),
      );
      return;
    }

    await (_db.update(
      _db.copies,
    )..where((copy) => copy.id.equals(copyId))).write(
      CopiesCompanion(
        status: const Value(CopyStatus.available),
        condition: Value(condition),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _promoteNextWaitingHold({
    required String titleId,
    required String copyId,
    required DateTime now,
    required DateTime today,
  }) async {
    final nextHold =
        await (_db.select(_db.reservations)
              ..where(
                (hold) =>
                    hold.titleId.equals(titleId) &
                    hold.closedAt.isNull() &
                    hold.status.equalsValue(ReservationStatus.waiting),
              )
              ..orderBy([(hold) => OrderingTerm(expression: hold.placedAt)]))
            .getSingleOrNull();
    if (nextHold == null) return;

    final rules = await _loadLoanRules();
    final expiresAt = addCalendarDays(today, rules.holdShelfDays);
    await (_db.update(
      _db.reservations,
    )..where((hold) => hold.id.equals(nextHold.id))).write(
      ReservationsCompanion(
        status: const Value(ReservationStatus.ready),
        readyCopyId: Value(copyId),
        readyAt: Value(now),
        expiresAt: Value(expiresAt),
        updatedAt: Value(now),
      ),
    );
    await (_db.update(
      _db.copies,
    )..where((copy) => copy.id.equals(copyId))).write(
      CopiesCompanion(
        status: const Value(CopyStatus.reserved),
        updatedAt: Value(now),
      ),
    );
  }

  Future<EffectiveLoanRules> _loadEffectiveRules(String memberTypeId) async {
    final typeRow = await (_db.select(
      _db.memberTypes,
    )..where((type) => type.id.equals(memberTypeId))).getSingleOrNull();
    if (typeRow == null) {
      throw const NotFoundException('That member type was not found.');
    }
    final rulesRow =
        await (_db.select(_db.loanRules)..where(
              (rules) => rules.id.equals(LoanRules.singletonId),
            ))
            .getSingleOrNull();
    if (rulesRow == null) {
      throw const NotFoundException('Loan rules have not been configured.');
    }
    return resolveLoanRules(rulesRow.toDomain(), typeRow.toDomain());
  }

  Future<EffectiveLoanRules> _loadEffectiveRulesForMember(
    String memberId,
  ) async {
    final memberRow = await (_db.select(
      _db.members,
    )..where((member) => member.id.equals(memberId))).getSingleOrNull();
    if (memberRow == null) {
      throw const NotFoundException('That member was not found.');
    }
    return await _loadEffectiveRules(memberRow.memberTypeId);
  }

  Future<LoanRulesRow> _loadLoanRules() async {
    final rulesRow =
        await (_db.select(_db.loanRules)..where(
              (rules) => rules.id.equals(LoanRules.singletonId),
            ))
            .getSingleOrNull();
    if (rulesRow == null) {
      throw const NotFoundException('Loan rules have not been configured.');
    }
    return rulesRow;
  }

  Future<int> _countOpenLoans(String memberId) {
    final count = _db.loans.id.count();
    return (_db.selectOnly(_db.loans)
          ..addColumns([count])
          ..where(
            _db.loans.memberId.equals(memberId) & _db.loans.returnedAt.isNull(),
          ))
        .getSingle()
        .then((row) => row.read(count) ?? 0);
  }

  Future<bool> _memberHasOverdueLoans(String memberId) async {
    final today = dateOnly(DateTime.now());
    final row =
        await (_db.select(_db.loans)..where(
              (loan) =>
                  loan.memberId.equals(memberId) &
                  loan.returnedAt.isNull() &
                  loan.dueAt.isSmallerThanValue(_dates.toSql(today)),
            ))
            .getSingleOrNull();
    return row != null;
  }

  Future<Money> _outstandingFines(String memberId) async {
    final row = await _db
        .customSelect(
          '''
SELECT COALESCE(SUM(assessed - paid - waived), 0) AS outstanding
FROM fines
WHERE member_id = ?
  AND paid + waived < assessed
''',
          variables: [Variable<String>(memberId)],
        )
        .getSingle();
    return Money(row.read<int>('outstanding'));
  }

  Future<int> _countWaitingHolds(String titleId) {
    final count = _db.reservations.id.count(
      filter:
          _db.reservations.titleId.equals(titleId) &
          _db.reservations.closedAt.isNull() &
          _db.reservations.status.equalsValue(ReservationStatus.waiting),
    );
    return (_db.selectOnly(
      _db.reservations,
    )..addColumns([count])).getSingle().then((row) => row.read(count) ?? 0);
  }

  Future<int> _countActiveHolds(String memberId) {
    final count = _db.reservations.id.count();
    return (_db.selectOnly(_db.reservations)
          ..addColumns([count])
          ..where(
            _db.reservations.memberId.equals(memberId) &
                _db.reservations.closedAt.isNull(),
          ))
        .getSingle()
        .then((row) => row.read(count) ?? 0);
  }

  Future<Loan?> _loadLoanById(String id) async {
    final row = await (_db.select(
      _db.loans,
    )..where((loan) => loan.id.equals(id))).getSingleOrNull();
    if (row == null) return null;

    final copy = await (_db.select(
      _db.copies,
    )..where((item) => item.id.equals(row.copyId))).getSingleOrNull();
    final member = await (_db.select(
      _db.members,
    )..where((item) => item.id.equals(row.memberId))).getSingleOrNull();
    final title = copy == null
        ? null
        : await (_db.select(
            _db.titles,
          )..where((item) => item.id.equals(copy.titleId))).getSingleOrNull();

    return row.toDomain(
      barcode: copy?.barcode,
      titleId: copy?.titleId,
      titleName: title?.title,
      memberName: member?.fullName,
    );
  }

  void _rejectArchivedMember(DateTime? archivedAt) {
    if (archivedAt != null) {
      throw const ConflictException('That member has been archived.');
    }
  }

  void _rejectSuspendedMember(DateTime? suspendedAt) {
    if (suspendedAt != null) {
      throw const ConflictException('That member is suspended.');
    }
  }

  void _rejectExpiredMember(DateTime? expiresAt, DateTime today) {
    if (expiresAt != null && dateOnly(expiresAt).isBefore(today)) {
      throw const ConflictException('That member membership has expired.');
    }
  }

  @override
  Future<LoanListResult> findOpenLoans(LoanQuery query) =>
      _loanDataSource.findOpenLoans(query);

  @override
  Future<LoanListResult> findLoans(LoanQuery query) =>
      _loanDataSource.findLoans(query);

  @override
  Future<Loan?> findLoan(String id) => _loanDataSource.findLoanById(id);

  @override
  Future<FineListResult> findFines(FineQuery query) =>
      _fineDataSource.findFines(query);

  @override
  Future<Fine?> findFine(String id) => _fineDataSource.findFineById(id);

  @override
  Future<ReservationListResult> findReservations(ReservationQuery query) =>
      _reservationDataSource.findReservations(query);

  @override
  Future<Reservation?> findReservation(String id) =>
      _reservationDataSource.findReservationById(id);
}
