import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/core/money/money.dart';

part 'title.freezed.dart';

/// One work in the catalogue.
@freezed
abstract class Title with _$Title {
  const factory Title({
    required String id,
    required String title,
    required String author,
    required String formatId,
    required String formatName,
    required Money replacementCost,
    required bool lendable,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int copyCount,
    required int availableCount,
    String? formatCode,
    String? subtitle,
    String? isbn,
    String? publisher,
    int? publishedYear,
    String? edition,
    @Default('English') String language,
    int? pages,
    @Default(<String>[]) List<String> subjects,
    String? description,
    String? shelf,
    DateTime? archivedAt,
  }) = _Title;

  const Title._();

  bool get isArchived => archivedAt != null;

  String get addedOn => AppDateFormat.format(createdAt);

  String get year => publishedYear?.toString() ?? '';

  String get initial =>
      title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();
}
