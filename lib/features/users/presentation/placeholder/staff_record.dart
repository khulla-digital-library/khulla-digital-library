import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/domain/user_status.dart';

/// One staff account, as the register lists it.
///
/// A preview model, not a domain entity: it exists so the screens can be
/// designed, reviewed and demonstrated before `staff` is a table. When the
/// table lands this file goes and the pages take a domain model instead.
class StaffRecord {
  const StaffRecord({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.lastActive,
  });

  /// Stable identity, the account's row id once there is one.
  final String id;

  /// The person's name as they signed up.
  final String name;

  /// The address they sign in with.
  final String email;

  /// What they are allowed to do.
  final UserRole role;

  /// Whether they can sign in today.
  final UserStatus status;

  /// When they were last at a desk, already formatted. Null means never.
  final String? lastActive;

  /// The circle's two letters.
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    final first = words.first;
    final last = words.length > 1 ? words.last : '';
    final head = first.isEmpty ? '' : first.substring(0, 1);
    final tail = last.isEmpty
        ? (first.length > 1 ? first.substring(1, 2) : '')
        : last.substring(0, 1);
    return '$head$tail'.toUpperCase();
  }
}
