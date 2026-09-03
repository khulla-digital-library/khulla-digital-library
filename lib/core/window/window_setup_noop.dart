import 'package:khulla/core/config/app_config.dart';

/// No-op on web and mobile, where the app does not own its window.
///
/// Takes [config] so the signature matches the desktop implementation and
/// `bootstrap` needs no platform check of its own.
Future<void> configureAppWindow(AppConfig config) async {}
