import 'package:khulla/features/catalog/copy/presentation/placeholder/label_queue_entry.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';

/// The queue a librarian would find after accessioning a small delivery.
///
/// Seeded rather than empty so the screen shows its working shape first; the
/// empty state is one "clear the queue" away.
List<LabelQueueEntry> initialLabelQueue() => [
  for (final copy in placeholderCopies.take(4)) LabelQueueEntry(copy: copy),
];

/// The library's name, as it prints on a property label.
const String placeholderLabelLibrary = 'Khulla Community Library';
