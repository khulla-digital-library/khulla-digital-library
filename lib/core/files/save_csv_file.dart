// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:khulla/core/files/saved_text_file.dart';

/// Writes rows as CSV to a location the operator picked.
///
/// A field containing a comma, a quote or a newline is wrapped in quotes with
/// its own quotes doubled — the one escaping rule CSV has. Returns null when
/// the operator cancels the save dialog, the same as `saveTextFile`.
Future<SavedTextFile?> saveCsvFile({
  required String filename,
  required List<String> header,
  required List<List<String>> rows,
}) async {
  final buffer = StringBuffer()..writeln(_csvRow(header));
  for (final row in rows) {
    buffer.writeln(_csvRow(row));
  }

  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(buffer.toString())),
    mimeType: 'text/csv',
    name: filename,
  );
  if (kIsWeb) {
    await file.saveTo(filename);
    return SavedTextFile(filename: filename);
  }

  final location = await getSaveLocation(suggestedName: filename);
  if (location == null) return null;

  await file.saveTo(location.path);
  return SavedTextFile(filename: filename, path: location.path);
}

String _csvRow(List<String> fields) => fields.map(_csvField).join(',');

String _csvField(String value) {
  var field = value;
  // Neutralize formula injection: a cell starting with = + - @ (or a tab/CR
  // that trims to one) executes as a formula when the CSV is opened in a
  // spreadsheet. Prefixing with a single quote keeps the text visible while
  // stopping evaluation.
  if (field.isNotEmpty &&
      const ['=', '+', '-', '@', '\t', '\r'].contains(field[0])) {
    field = "'$field";
  }
  final needsQuoting =
      field.contains(',') ||
      field.contains('"') ||
      field.contains('\n') ||
      field.contains('\r');
  if (!needsQuoting) return field;
  return '"${field.replaceAll('"', '""')}"';
}
