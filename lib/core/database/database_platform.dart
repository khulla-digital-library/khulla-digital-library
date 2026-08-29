/// Platform-specific SQLite wiring.
///
/// One SQLite API — `package:sqflite_common` — over three backends:
///
/// | Platform | Backend | Package |
/// | --- | --- | --- |
/// | Android, iOS | system SQLite via the platform channel | `sqflite` |
/// | Windows, Linux, macOS | SQLite over `dart:ffi` | `sqflite_common_ffi` |
/// | Web | SQLite compiled to WebAssembly, stored in IndexedDB | `sqflite_common_ffi_web` |
///
/// The web implementation is the fallback branch so that any target without
/// `dart:io` still resolves, and `dart.library.io` selects the native one.
///
/// The web backend needs `sqlite3.wasm` and `sqflite_sw.js` present in `web/`.
/// They are checked in, and `make db-web` refreshes them after an upgrade.
library;

export 'database_platform_web.dart'
    if (dart.library.io) 'database_platform_io.dart';
