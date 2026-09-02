import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/members/domain/member_category.dart';
import 'package:khulla/features/members/domain/member_status.dart';

/// One borrower on the register.
class MemberRecord {
  const MemberRecord({
    required this.id,
    required this.name,
    required this.cardNumber,
    required this.category,
    required this.status,
    required this.joined,
    required this.expires,
    required this.loansOut,
    required this.overdue,
    required this.finesOwed,
    required this.borrowedAllTime,
    this.email,
    this.phone,
    this.address,
    this.dateOfBirth,
    this.guardian,
    this.notes,
  });

  final String id;
  final String name;
  final String cardNumber;
  final MemberCategory category;
  final MemberStatus status;
  final String joined;
  final String expires;

  /// How many copies they are holding right now.
  final int loansOut;

  /// How many of those are late.
  final int overdue;

  /// What they owe, in minor units.
  final Money finesOwed;

  /// Everything they have ever borrowed, for the record's own stat row.
  final int borrowedAllTime;

  final String? email;
  final String? phone;
  final String? address;
  final String? dateOfBirth;

  /// The adult responsible for a child's card.
  final String? guardian;

  final String? notes;

  /// Initials for the avatar, cased here rather than in the design system.
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
