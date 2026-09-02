/// Desktop window chrome.
///
/// Native desktop is the only target with an OS window to size, title, and
/// show; web and mobile resolve to a no-op so `bootstrap` stays branch-free.
library;

export 'window_setup_noop.dart' if (dart.library.io) 'window_setup_io.dart';
