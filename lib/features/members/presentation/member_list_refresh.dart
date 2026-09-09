import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Lets the members list reload when a member is added from shell chrome.
@lazySingleton
class MemberListRefresh {
  VoidCallback? reload;

  void notifyChanged() => reload?.call();
}
