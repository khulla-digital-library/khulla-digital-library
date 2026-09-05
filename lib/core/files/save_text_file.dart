import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:khulla/core/files/saved_text_file.dart';

/// Writes a small text file the operator picked a location for.
///
/// Returns null when they cancel the save dialog.
Future<SavedTextFile?> saveTextFile({
  required String filename,
  required String contents,
}) async {
  final location = await getSaveLocation(suggestedName: filename);
  if (location == null) return null;

  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(contents)),
    mimeType: 'text/plain',
    name: filename,
  );
  await file.saveTo(location.path);
  return SavedTextFile(filename: filename, path: location.path);
}
