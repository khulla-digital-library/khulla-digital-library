import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/money/currency.dart';

part 'library_profile.freezed.dart';

/// Who the library is and how to reach it.
///
/// Set during first-run onboarding and edited under Settings. Amounts are
/// always stored in minor units; [currency] only changes how they render.
@freezed
abstract class LibraryProfile with _$LibraryProfile {
  const factory LibraryProfile({
    required String name,
    required AppCurrency currency,
    required DateTime createdAt,
    String? branch,
    String? email,
    String? phone,
    String? address,
    String? openingHours,
    @Default('KH-') String barcodePrefix,
    @Default(1) int barcodeNextValue,
    DateTime? updatedAt,
  }) = _LibraryProfile;
}
