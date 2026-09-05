import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/money/currency.dart';

part 'library_profile.freezed.dart';

/// Who the library is and what it charges in.
///
/// Set during first-run onboarding and edited afterwards under Settings.
/// Everything else a library profile could hold — branch, address, phone,
/// opening hours — has a sensible default and is deliberately not asked for
/// at setup: a librarian who wants to catalogue a book should not have to
/// fill in an address first.
@freezed
abstract class LibraryProfile with _$LibraryProfile {
  const factory LibraryProfile({
    required String name,
    required AppCurrency currency,
    required DateTime createdAt,
  }) = _LibraryProfile;
}
