/// A person or organisation credited on a title.
class CatalogAuthor {
  const CatalogAuthor({
    required this.id,
    required this.name,
    required this.titleCount,
    this.lifespan,
    this.nationality,
    this.biography,
  });

  final String id;
  final String name;
  final int titleCount;
  final String? lifespan;
  final String? nationality;
  final String? biography;

  /// Initials for the avatar badge, cased here because the design system
  /// takes ready-made letters rather than deriving them from a name.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first;
    final last = words.length > 1 ? words.last : '';
    final head = first.isEmpty ? '' : first.substring(0, 1);
    final tail = last.isEmpty
        ? (first.length > 1 ? first.substring(1, 2) : '')
        : last.substring(0, 1);
    return '$head$tail'.toUpperCase();
  }
}
