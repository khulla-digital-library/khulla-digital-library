/// Builds the denormalized search column for list queries.
String buildSearchText(Iterable<String> parts) {
  final buffer = StringBuffer();
  for (final part in parts) {
    final normalized = part.trim().toLowerCase().replaceAll(
      RegExp(r'\s+'),
      ' ',
    );
    if (normalized.isEmpty) continue;
    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(normalized);
  }
  return buffer.toString();
}

/// Stores subjects as `|history|nepal|` for exact LIKE matching.
String encodeSubjects(Iterable<String> subjects) {
  final values = [
    for (final subject in subjects)
      if (subject.trim().isNotEmpty) subject.trim().toLowerCase(),
  ];
  if (values.isEmpty) return '';
  return '|${values.join('|')}|';
}

List<String> decodeSubjects(String stored) {
  if (stored.isEmpty) return const [];
  return [
    for (final part in stored.split('|'))
      if (part.trim().isNotEmpty) part.trim(),
  ];
}
