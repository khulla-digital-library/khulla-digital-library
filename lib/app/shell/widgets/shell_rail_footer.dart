import 'package:khulla/app/shell/widgets/shell_account_chip.dart';
import 'package:khulla/app/shell/widgets/shell_notifications_button.dart';
import 'package:khulla/app/shell/widgets/shell_theme_toggle.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The app-wide chrome, parked at the foot of the rail.
///
/// Search, notifications, the theme switch and who is signed in are the same
/// on every screen, so they belong beside the navigation that is also the
/// same on every screen — not across the top, where they crowded out the one
/// thing that differs per screen: what this section is and what you can do
/// to it. It also puts the account control within a mouse-flick of the rail
/// the operator is already using.
class ShellRailFooter extends StatelessWidget {
  const ShellRailFooter({required this.extended, super.key});

  /// Whether the rail is showing labels. Collapsed stacks glyphs instead.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;

    if (!extended) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(height: spacing.md, color: colors.hairline),
          AppIconButton(
            icon: AppIcons.search,
            tooltip: l10n.shellSearchHint,
            onPressed: () => showNotWiredToast(context),
          ),
          const ShellNotificationsButton(),
          const ShellThemeToggle(),
          SizedBox(height: spacing.xxs),
          const ShellAccountChip(compact: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSearchField(
          hintText: l10n.shellSearchHint,
          clearTooltip: l10n.commonClearSearch,
          dense: true,
          onChanged: (_) {},
          onSubmitted: (_) => showNotWiredToast(context),
        ),
        Divider(height: spacing.md, color: colors.hairline),
        const Row(
          children: [
            Expanded(child: ShellAccountChip()),
            ShellNotificationsButton(),
            ShellThemeToggle(),
          ],
        ),
      ],
    );
  }
}
