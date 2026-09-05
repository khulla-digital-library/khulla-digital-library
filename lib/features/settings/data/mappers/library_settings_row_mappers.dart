import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/features/settings/data/tables/library_settings.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';

/// Row ↔ domain conversions for the single library-settings row.
extension LibrarySettingsRowX on LibrarySettingsRow {
  LibraryProfile toDomain() =>
      LibraryProfile(name: name, currency: currency, createdAt: createdAt);
}

extension LibraryProfileX on LibraryProfile {
  /// The row to write. The id is pinned to the singleton value so a save is
  /// always an upsert over the same row rather than a second profile.
  LibrarySettingsCompanion toCompanion() => LibrarySettingsCompanion(
    id: const Value(LibrarySettings.singletonId),
    name: Value(name),
    currency: Value(currency),
    createdAt: Value(createdAt),
  );
}
