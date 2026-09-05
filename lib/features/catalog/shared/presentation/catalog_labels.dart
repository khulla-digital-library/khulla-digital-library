import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/features/catalog/title/domain/models/title_format.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Localized names and icons for reference formats and copy standing.
extension TitleFormatCodeX on String? {
  AppIconSpec get formatIcon => switch (this) {
    'book' => AppIcons.book,
    'journal' => AppIcons.article,
    'magazine' => AppIcons.openBook,
    'audiobook' => AppIcons.audio,
    'video' => AppIcons.video,
    'ebook' => AppIcons.devices,
    _ => AppIcons.book,
  };

  String formatLabel(AppLocalizations l10n) => switch (this) {
    'book' => l10n.formatBook,
    'journal' => l10n.formatJournal,
    'magazine' => l10n.formatMagazine,
    'audiobook' => l10n.formatAudio,
    'video' => l10n.formatVideo,
    'ebook' => l10n.formatDigital,
    _ => l10n.formatBook,
  };
}

extension TitleFormatX on TitleFormat {
  AppIconSpec get icon => code.formatIcon;

  String label(AppLocalizations l10n) => switch (code) {
    null => name,
    final value => value.formatLabel(l10n),
  };
}

extension CopyStatusX on CopyStatus {
  String label(AppLocalizations l10n) => switch (this) {
    CopyStatus.available => l10n.statusAvailable,
    CopyStatus.onLoan => l10n.statusOnLoan,
    CopyStatus.reserved => l10n.statusReserved,
    CopyStatus.lost => l10n.statusLost,
    CopyStatus.damaged => l10n.statusDamaged,
    CopyStatus.withdrawn => l10n.statusWithdrawn,
  };

  AppStatusTone get tone => switch (this) {
    CopyStatus.available => AppStatusTone.success,
    CopyStatus.onLoan => AppStatusTone.brand,
    CopyStatus.reserved => AppStatusTone.info,
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
