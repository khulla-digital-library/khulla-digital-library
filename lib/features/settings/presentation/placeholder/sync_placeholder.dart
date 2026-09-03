import 'package:khulla_ui/khulla_ui.dart';

/// One snapshot written to the remote store.
class SyncSnapshot {
  const SyncSnapshot({
    required this.when,
    required this.size,
    required this.outcome,
  });

  /// When it was written, already formatted.
  final String when;

  /// How large it was, already formatted.
  final String size;

  /// How it went.
  final SyncOutcome outcome;
}

/// How a snapshot ended.
enum SyncOutcome { written, failed, skipped }

/// The tone each outcome paints.
extension SyncOutcomeX on SyncOutcome {
  AppStatusTone get tone => switch (this) {
    SyncOutcome.written => AppStatusTone.success,
    SyncOutcome.failed => AppStatusTone.danger,
    SyncOutcome.skipped => AppStatusTone.neutral,
  };
}

/// Where the encrypted snapshot is written.
enum SyncProvider { none, folder, webdav, s3 }

/// The snapshot history the screen is designed against.
const List<SyncSnapshot> placeholderSnapshots = [
  SyncSnapshot(
    when: 'Today, 09:15',
    size: '18.4 MB',
    outcome: SyncOutcome.written,
  ),
  SyncSnapshot(
    when: 'Yesterday, 18:02',
    size: '18.2 MB',
    outcome: SyncOutcome.written,
  ),
  SyncSnapshot(
    when: 'Yesterday, 09:04',
    size: '—',
    outcome: SyncOutcome.skipped,
  ),
  SyncSnapshot(
    when: '2 days ago, 18:00',
    size: '—',
    outcome: SyncOutcome.failed,
  ),
  SyncSnapshot(
    when: '2 days ago, 09:11',
    size: '17.9 MB',
    outcome: SyncOutcome.written,
  ),
];

/// When the last snapshot was written.
const String placeholderLastSynced = 'Today, 09:15';

/// When the next one is due.
const String placeholderNextSync = 'Today, 18:00';
