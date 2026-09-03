import 'package:khulla/features/catalog/shared/domain/catalog_format.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Localized names and semantic tones for the catalogue's enums.
///
/// The mapping lives on the presentation side on purpose: the enums say what
/// a copy *is*, and this file says how it reads and which colour family it
/// draws from — neither of which the design system or the domain should know.
extension CatalogFormatX on CatalogFormat {
  String label(AppLocalizations l10n) => switch (this) {
    CatalogFormat.book => l10n.formatBook,
    CatalogFormat.journal => l10n.formatJournal,
    CatalogFormat.magazine => l10n.formatMagazine,
    CatalogFormat.audio => l10n.formatAudio,
    CatalogFormat.video => l10n.formatVideo,
    CatalogFormat.digital => l10n.formatDigital,
  };

  AppIconSpec get icon => switch (this) {
    CatalogFormat.book => AppIcons.book,
    CatalogFormat.journal => AppIcons.article,
    CatalogFormat.magazine => AppIcons.openBook,
    CatalogFormat.audio => AppIcons.audio,
    CatalogFormat.video => AppIcons.video,
    CatalogFormat.digital => AppIcons.devices,
  };
}

extension CopyStatusX on CopyStatus {
  String label(AppLocalizations l10n) => switch (this) {
    CopyStatus.available => l10n.statusAvailable,
    CopyStatus.onLoan => l10n.statusOnLoan,
    CopyStatus.reserved => l10n.statusReserved,
    CopyStatus.overdue => l10n.statusOverdue,
    CopyStatus.lost => l10n.statusLost,
    CopyStatus.damaged => l10n.statusDamaged,
    CopyStatus.withdrawn => l10n.statusWithdrawn,
  };

  AppStatusTone get tone => switch (this) {
    CopyStatus.available => AppStatusTone.success,
    CopyStatus.onLoan => AppStatusTone.brand,
    CopyStatus.reserved => AppStatusTone.info,
    CopyStatus.overdue => AppStatusTone.danger,
    CopyStatus.lost => AppStatusTone.danger,
    CopyStatus.damaged => AppStatusTone.warning,
    CopyStatus.withdrawn => AppStatusTone.neutral,
  };
}

extension CopyConditionX on CopyCondition {
  String label(AppLocalizations l10n) => switch (this) {
    CopyCondition.asNew => l10n.conditionNew,
    CopyCondition.good => l10n.conditionGood,
    CopyCondition.fair => l10n.conditionFair,
    CopyCondition.poor => l10n.conditionPoor,
  };
}
