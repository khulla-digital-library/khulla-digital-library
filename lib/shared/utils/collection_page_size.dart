import 'dart:math';

import 'package:khulla_ui/khulla_ui.dart';

/// Fewest rows to fetch when the viewport is very short.
const int kCollectionPageSizeMin = 5;

/// Rows to fetch on a compact window where the whole page scrolls together.
const int kCollectionPageSizeCompact = 30;

/// How many table body rows fit in [tableBodyHeight].
///
/// [tableBodyHeight] is the height of the scroll viewport in a collection
/// list page — the [Expanded] slot on a desk window, not the full screen.
/// The pinned header row is subtracted before dividing by row height.
int computeCollectionPageSize({
  required double tableBodyHeight,
  required AppMetrics metrics,
}) {
  final body = tableBodyHeight - metrics.tableHeaderHeight;
  if (body <= 0) return kCollectionPageSizeMin;
  return max(kCollectionPageSizeMin, (body / metrics.tableRowHeight).floor());
}
