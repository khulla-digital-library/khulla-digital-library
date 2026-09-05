import 'package:khulla/app/shell/widgets/shell_account_chip.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The app-wide chrome, parked at the foot of the rail.
///
/// Who is signed in is the same on every screen, so the account control
/// belongs beside the navigation that is also the same on every screen — not
/// across the top, where it crowded out the one thing that differs per screen:
/// what this section is and what you can do to it.
class ShellRailFooter extends StatelessWidget {
  const ShellRailFooter({required this.extended, super.key});

  /// Whether the rail is showing labels. Collapsed stacks glyphs instead.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: spacing.md, color: colors.hairline),
        ShellAccountChip(compact: !extended),
      ],
    );
  }
}
