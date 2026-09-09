import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:khulla/core/files/saved_text_file.dart';

/// Writes rows as CSV to a location the operator picked.
///
/// A field containing a comma, a quote or a newline is wrapped in quotes with
/// its own quotes doubled — the one escaping rule CSV has. Returns null when
/// the operator cancels the save dialog, the same as [saveTextFile].
Future<SavedTextFile?> saveCsvFile({
  required String filename,
  required List<String> header,
  required List<List<String>> rows,
}) async {
  final buffer = StringBuffer()..writeln(_csvRow(header));
  for (final row in rows) {
    buffer.writeln(_csvRow(row));
  }

  final location = await getSaveLocation(suggestedName: filename);
  if (location == null) return null;

  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(buffer.toString())),
    mimeType: 'text/csv',
    name: filename,
  );
  await file.saveTo(location.path);
  return SavedTextFile(filename: filename, path: location.path);
}

String _csvRow(List<String> fields) => fields.map(_csvField).join(',');

String _csvField(String value) {
  final needsQuoting =
      value.contains(',') || value.contains('"') || value.contains('\n');
  if (!needsQuoting) return value;
  return '"${value.replaceAll('"', '""')}"';
}
