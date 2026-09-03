import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/shared/domain/catalog_format.dart';

/// One work in the catalogue, as the screens need it.
///
/// A stand-in until the `titles` table exists: the fields are the ones the
/// list, the detail pane and the editor actually render, so when the query
/// lands it replaces this class rather than the widgets around it.
class CatalogTitle {
  const CatalogTitle({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publisher,
    required this.year,
    required this.format,
    required this.shelf,
    required this.copies,
    required this.available,
    required this.addedOn,
    required this.replacementCost,
    this.subtitle,
    this.edition,
    this.language = 'English',
    this.pages,
    this.subjects = const [],
    this.description,
    this.lendable = true,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String author;
  final String isbn;
  final String publisher;
  final String year;
  final String? edition;
  final String language;
  final CatalogFormat format;
  final int? pages;
  final List<String> subjects;
  final String shelf;
  final String? description;

  /// How many physical items exist under this title.
  final int copies;

  /// How many of them are on the shelf right now.
  final int available;

  final String addedOn;

  /// What one copy costs to replace, charged when a copy is lost.
  final Money replacementCost;

  /// False for reference works that never leave the building.
  final bool lendable;

  /// The one letter shown in the title's badge, taken here rather than in the
  /// design system, which takes ready-made text and does not do locale.
  String get initial =>
      title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();
}
