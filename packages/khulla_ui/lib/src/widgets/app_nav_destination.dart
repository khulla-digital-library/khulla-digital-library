import 'package:khulla_ui/khulla_ui.dart';

/// A single navigation destination, shared by [AppNavBar] and [AppNavRail].
///
/// One destination list drives both the compact bottom bar and the wide side
/// rail, so a window that is resized across a breakpoint keeps the same
/// destinations in the same order.
class AppNavDestination {
  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Glyph shown while the destination is not selected.
  final Widget icon;

  /// Glyph shown while the destination is selected.
  final Widget selectedIcon;

  /// Short destination name. Doubles as the rail tooltip when collapsed.
  final String label;
}
