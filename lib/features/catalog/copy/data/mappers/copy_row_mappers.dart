import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/features/catalog/copy/domain/models/copy.dart';

extension CopyRowMapper on CopyRow {
  Copy toDomain({
    required String titleName,
    String? borrower,
    DateTime? dueAt,
  }) => Copy(
    id: id,
    barcode: barcode,
    titleId: titleId,
    titleName: titleName,
    shelf: shelf ?? '',
    condition: condition,
    status: status,
    acquiredAt: acquiredAt,
    notes: notes,
    archivedAt: archivedAt,
    borrower: borrower,
    dueAt: dueAt,
  );
}

extension CopyDomainMapper on Copy {
  CopiesCompanion toCompanion({
    required DateTime createdAt,
    required DateTime updatedAt,
  }) => CopiesCompanion(
    id: Value(id),
    titleId: Value(titleId),
    barcode: Value(barcode),
    shelf: Value(shelf.isEmpty ? null : shelf),
    condition: Value(condition),
    status: Value(status),
    acquiredAt: Value(acquiredAt),
    notes: Value(notes),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    archivedAt: Value(archivedAt),
  );
}
