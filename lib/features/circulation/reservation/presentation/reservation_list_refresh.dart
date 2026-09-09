import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Lets the reservations list reload when a hold is placed from shell chrome.
@lazySingleton
class ReservationListRefresh {
  VoidCallback? reload;

  void notifyChanged() => reload?.call();
}
