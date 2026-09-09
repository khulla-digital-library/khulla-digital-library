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
