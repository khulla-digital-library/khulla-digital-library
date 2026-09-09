import 'package:web/web.dart' as web;

/// Reloads the page. The web build has no process to end, only a document to
/// reopen — a reload is what makes `driftDatabase()` reconnect to whatever
/// the restore or erase just wrote to OPFS or IndexedDB.
void restartApp() => web.window.location.reload();
