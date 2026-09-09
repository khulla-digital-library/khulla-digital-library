import 'package:freezed_annotation/freezed_annotation.dart';

part 'title_format.freezed.dart';

/// An editable catalogue format — book, journal, audiobook, and so on.
@freezed
abstract class TitleFormat with _$TitleFormat {
  const factory TitleFormat({
    required String id,
    required String name,
    required int sortOrder,
    required bool isSystem,
    required DateTime createdAt,
    String? code,
    DateTime? archivedAt,
  }) = _TitleFormat;

  const TitleFormat._();

  bool get isArchived => archivedAt != null;
}
