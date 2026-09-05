import 'package:injectable/injectable.dart';
import 'package:khulla/core/money/currency.dart';
import 'package:khulla/core/money/money_format.dart';
import 'package:khulla/features/settings/data/library_settings_local_data_source.dart';
import 'package:khulla/features/settings/domain/library_settings_repository.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';

/// [LibrarySettingsRepository] over the local catalogue.
///
/// It also owns the one side effect a saved profile has outside the database:
/// [MoneyFormat.current]. Putting it here means every path that writes a
/// currency — onboarding, the settings screen, a restore — applies it, rather
/// than each remembering to. Nothing rebuilds on its own when it changes, so
/// a screen that switches currency still has to trigger its own rebuild.
@LazySingleton(as: LibrarySettingsRepository)
class LibrarySettingsRepositoryImpl implements LibrarySettingsRepository {
  LibrarySettingsRepositoryImpl(this._dataSource);

  final LibrarySettingsLocalDataSource _dataSource;

  @override
  Future<LibraryProfile?> findProfile() async {
    final profile = await _dataSource.findProfile();
    if (profile != null) MoneyFormat.current = profile.currency.format;
    return profile;
  }

  @override
  Future<LibraryProfile> saveProfile({
    required String name,
    required AppCurrency currency,
  }) async {
    final existing = await _dataSource.findProfile();
    final saved = await _dataSource.saveProfile(
      LibraryProfile(
        name: name.trim(),
        currency: currency,
        // Kept from the first save: this is when the library was set up, not
        // when its name was last edited.
        createdAt: existing?.createdAt ?? DateTime.now(),
      ),
    );
    MoneyFormat.current = saved.currency.format;
    return saved;
  }
}
