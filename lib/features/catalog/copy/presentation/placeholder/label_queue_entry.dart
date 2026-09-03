import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_copy.dart';

/// One copy waiting for its sticker, and how many of that sticker to print.
///
/// A copy needs a second label often enough — one peels off, one goes inside
/// the cover — that the queue counts labels rather than assuming one each.
class LabelQueueEntry {
  const LabelQueueEntry({required this.copy, this.count = 1});

  /// The copy the label identifies.
  final CatalogCopy copy;

  /// How many stickers to print for it.
  final int count;

  /// The same entry with [count] replaced, floored at one.
  LabelQueueEntry withCount(int next) =>
      LabelQueueEntry(copy: copy, count: next < 1 ? 1 : next);
}
