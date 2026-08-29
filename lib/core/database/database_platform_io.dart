import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

/// Native SQLite supports write-ahead logging, which keeps a long read (a
/// catalogue export) from blocking a concurrent write (a checkout).
const bool supportsWriteAheadLog = true;

/// Desktop talks to SQLite over `dart:ffi`; mobile goes through the platform
/// channel, which is the only backend with a system SQLite to talk to.
Future<DatabaseFactory> resolveDatabaseFactory() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    return databaseFactoryFfi;
  }
  return sqflite.databaseFactory;
}

/// Application support, not documents: the catalogue is app-managed state, so
/// it should not sit in a folder the user is invited to reorganise or sync.
Future<String> resolveDatabasePath(String fileName) async {
  final directory = await getApplicationSupportDirectory();
  if (!directory.existsSync()) {
    await directory.create(recursive: true);
  }
  return p.join(directory.path, fileName);
}
