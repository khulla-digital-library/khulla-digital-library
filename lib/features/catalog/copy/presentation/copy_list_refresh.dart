import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Lets the copies list reload when a copy is added from shell chrome.
@lazySingleton
class CopyListRefresh {
  VoidCallback? reload;

  void notifyChanged() => reload?.call();
}
