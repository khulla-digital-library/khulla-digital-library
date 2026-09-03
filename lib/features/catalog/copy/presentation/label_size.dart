import 'package:khulla/l10n/l10n.dart';

/// The sticker stocks the library keeps on the shelf behind the desk.
///
/// The millimetre sizes are the common thermal-label stocks; the logical
/// pixels are the preview's, scaled so the three sit beside each other at
/// roughly the ratio they have in the hand.
enum LabelSize {
  /// Spine labels — barcode and shelf mark only.
  small(width: 190, height: 105),

  /// The default accession sticker: title, barcode, shelf mark.
  medium(width: 252, height: 152),

  /// Property labels for oversized stock, with the library's name.
  large(width: 316, height: 182);

  LabelSize({required this.width, required this.height});

  /// The preview's width in logical pixels.
  final double width;

  /// The preview's height in logical pixels.
  final double height;

  /// The stock's name and its millimetre size.
  String label(AppLocalizations l10n) => switch (this) {
    LabelSize.small => l10n.labelsSizeSmall,
    LabelSize.medium => l10n.labelsSizeMedium,
    LabelSize.large => l10n.labelsSizeLarge,
  };
}
