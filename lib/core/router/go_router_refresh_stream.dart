import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart' show GoRouter;

/// Bridges a [Stream] into a [Listenable] so [GoRouter] re-evaluates redirects
/// whenever the stream emits (e.g. auth or session status changes).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
