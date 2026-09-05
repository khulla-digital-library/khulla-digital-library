import 'package:khulla/core/money/money.dart';

/// One work in the catalogue, as OPAC and author screens need it until wired.
///
/// Kept for screens that still read mock data. Wired catalogue screens use
/// the domain title model instead.
class CatalogTitle {
  const CatalogTitle({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.publisher,
    required this.year,
    required this.formatCode,
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
  final String formatCode;
  final int? pages;
  final List<String> subjects;
  final String shelf;
  final String? description;
  final int copies;
  final int available;
  final String addedOn;
  final Money replacementCost;
  final bool lendable;

  String get initial =>
      title.isEmpty ? '?' : title.substring(0, 1).toUpperCase();
}
