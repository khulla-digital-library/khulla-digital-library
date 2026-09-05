import 'package:khulla/features/catalog/label/domain/models/label_size.dart';
import 'package:khulla/l10n/l10n.dart';

/// Localized names for the sticker stocks the library keeps behind the desk.
extension LabelSizeX on LabelSize {
  /// The stock's name and its millimetre size.
  String label(AppLocalizations l10n) => switch (this) {
    LabelSize.small => l10n.labelsSizeSmall,
    LabelSize.medium => l10n.labelsSizeMedium,
    LabelSize.large => l10n.labelsSizeLarge,
  };
}
