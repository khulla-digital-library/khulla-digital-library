import 'package:khulla/core/money/currency.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';

/// The library's own record: its name and the currency it charges in.
abstract interface class LibrarySettingsRepository {
  /// The profile, or null on a catalogue that has never been set up.
  Future<LibraryProfile?> findProfile();

  /// Creates or replaces the profile and applies its currency to the app's
  /// money formatting.
  Future<LibraryProfile> saveProfile({
    required String name,
    required AppCurrency currency,
  });
}
