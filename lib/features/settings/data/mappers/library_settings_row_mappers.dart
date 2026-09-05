import 'package:drift/drift.dart';
import 'package:khulla/core/database/app_database.dart';
import 'package:khulla/features/settings/data/tables/library_settings.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';

extension LibrarySettingsRowX on LibrarySettingsRow {
  LibraryProfile toDomain() => LibraryProfile(
    name: name,
    currency: currency,
    createdAt: createdAt,
    branch: branch,
    email: email,
    phone: phone,
    address: address,
    openingHours: openingHours,
    barcodePrefix: barcodePrefix,
    barcodeNextValue: barcodeNextValue,
    updatedAt: updatedAt,
  );
}

extension LibraryProfileX on LibraryProfile {
  LibrarySettingsCompanion toCompanion() => LibrarySettingsCompanion(
    id: const Value(LibrarySettings.singletonId),
    name: Value(name),
    currency: Value(currency),
    branch: Value(branch),
    email: Value(email),
    phone: Value(phone),
    address: Value(address),
    openingHours: Value(openingHours),
    barcodePrefix: Value(barcodePrefix),
    barcodeNextValue: Value(barcodeNextValue),
    createdAt: Value(createdAt),
    updatedAt: Value(updatedAt),
  );
}
