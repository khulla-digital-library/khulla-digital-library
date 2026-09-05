import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart';

extension TitleRowMapper on TitleRow {
  Title toDomain({
    required String formatName,
    required int copyCount,
    required int availableCount,
    required List<String> subjects,
    String? formatCode,
  }) => Title(
    id: id,
    title: title,
    subtitle: subtitle,
    author: author,
    isbn: isbn,
    publisher: publisher,
    publishedYear: publishedYear,
    edition: edition,
    language: language,
    pages: pages,
    subjects: subjects,
    description: description,
    shelf: shelf,
    formatId: formatId,
    formatName: formatName,
    formatCode: formatCode,
    lendable: lendable,
    replacementCost: replacementCost,
    createdAt: createdAt,
    updatedAt: updatedAt,
    archivedAt: archivedAt,
    copyCount: copyCount,
    availableCount: availableCount,
  );
}

extension TitleDomainMapper on Title {
  TitlesCompanion toCompanion({required String searchText}) => TitlesCompanion(
    id: Value(id),
    title: Value(title),
    subtitle: Value(subtitle),
    author: Value(author),
    isbn: Value(isbn),
    publisher: Value(publisher),
    publishedYear: Value(publishedYear),
    edition: Value(edition),
    pages: Value(pages),
    formatId: Value(formatId),
    language: Value(language),
    subjects: Value(
      subjects.isEmpty
          ? ''
          : '|${subjects.map((s) => s.toLowerCase()).join('|')}|',
    ),
    description: Value(description),
    shelf: Value(shelf),
    lendable: Value(lendable),
    replacementCost: Value(replacementCost),
    searchText: Value(searchText),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
    archivedAt: Value(archivedAt),
  );
}
