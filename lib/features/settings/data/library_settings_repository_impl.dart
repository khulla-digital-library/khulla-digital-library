import 'package:injectable/injectable.dart';
import 'package:khulla/core/money/money_format.dart';
import 'package:khulla/features/settings/data/library_settings_local_data_source.dart';
import 'package:khulla/features/settings/domain/library_settings_repository.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';

/// [LibrarySettingsRepository] over the local catalogue.
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
  Future<LibraryProfile> saveProfile(LibraryProfile profile) async {
    final existing = await _dataSource.findProfile();
    final now = DateTime.now();
    final saved = await _dataSource.saveProfile(
      profile.copyWith(
        createdAt: existing?.createdAt ?? profile.createdAt,
        updatedAt: now,
      ),
    );
    MoneyFormat.current = saved.currency.format;
    return saved;
  }
}
