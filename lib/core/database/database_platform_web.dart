import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// The IndexedDB-backed virtual file system has no WAL mode — enabling it
/// would fail the pragma rather than fall back.
const bool supportsWriteAheadLog = false;

/// Runs SQLite in a web worker so a long query does not freeze the tab.
Future<DatabaseFactory> resolveDatabaseFactory() async => databaseFactoryFfiWeb;

/// On web there is no filesystem: the name is the IndexedDB store key, so the
/// flavor's file name doubles as its isolation boundary.
Future<String> resolveDatabasePath(String fileName) async => fileName;
