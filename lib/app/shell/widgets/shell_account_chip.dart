import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/users/presentation/placeholder/users_placeholder.dart';
import 'package:khulla/features/users/presentation/user_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Who is signed in, pinned to the trailing edge of the top bar.
///
/// It shows the name *and* the role because a shared desk machine is the
/// normal case in a library: the person about to waive a fine needs to see,
/// without opening a menu, whether they are signed in as themselves or as
/// whoever worked the morning shift.
class ShellAccountChip extends StatelessWidget {
  const ShellAccountChip({this.compact = false, super.key});

  /// Drops the name and role, leaving the avatar alone.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final staff = signedInStaff;

    return PopupMenuButton<int>(
      tooltip: l10n.shellAccountMenu,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          onTap: () => showNotWiredToast(context),
          child: _MenuRow(
            icon: Icons.person_outline_rounded,
            label: l10n.shellProfile,
          ),
        ),
        PopupMenuItem<int>(
          onTap: () => context.go(Routes.settings),
          child: _MenuRow(
            icon: Icons.settings_outlined,
            label: l10n.navSettings,
          ),
        ),
        PopupMenuItem<int>(
          onTap: () => showNotWiredToast(context),
          child: _MenuRow(
            icon: Icons.help_outline_rounded,
            label: l10n.shellHelp,
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<int>(
          onTap: () => showNotWiredToast(context),
          child: _MenuRow(
            icon: Icons.logout_rounded,
            label: l10n.shellSignOut,
            destructive: true,
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xxs,
          vertical: spacing.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(initials: staff.initials, size: 34),
            if (!compact) ...[
              SizedBox(width: spacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    staff.name,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colors.textHigh,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    staff.role.label(l10n),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(width: spacing.xxs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: colors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive
        ? context.colorScheme.error
        : context.colorScheme.onSurface;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: context.appSpacing.xs),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(color: color),
        ),
      ],
    );
  }
}
