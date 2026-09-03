import 'package:khulla_ui/khulla_ui.dart';

/// How an [AppErrorView] or [AppEmptyView] arranges itself.
///
/// The two layouts exist because a screen state and a section state need
/// different amounts of room: a catalogue that came back empty owns the whole
/// viewport, while the same message inside a dashboard card has one line to
/// work with.
enum AppFeedbackVariant {
  /// Centered column with an icon — fills the space a collection would take.
  centered,

  /// Left-aligned, no icon — sits inside a card that already has its own
  /// chrome and cannot spare the vertical room.
  inline;

  /// Whether this layout centers its content and shows an icon.
  bool get isCentered => this == AppFeedbackVariant.centered;
}
