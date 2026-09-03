import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/title/presentation/title_form_dialog.dart';
import 'package:khulla/features/members/presentation/pages/member_form_dialog.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The other things a desk shift starts with, as buttons rather than tiles.
///
/// These are actions, not content, and drawing each as a bordered card with
/// its own tinted glyph made four verbs look like four features. A wrap of
/// outline buttons says the same thing in a third of the height and reads as
/// something to press.
///
/// Checking a copy out is missing on purpose: it is the board's one primary
/// action and already sits in the control strip at the top. Repeating it here
/// would leave the page with two equally-weighted copies of the same button.
class DashboardQuickActions extends StatelessWidget {
  const DashboardQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        _QuickAction(
          label: l10n.dashboardReturnCopy,
          icon: AppIcons.checkIn,
          onPressed: () => context.go(Routes.circulationReturn),
        ),
        _QuickAction(
          label: l10n.dashboardAddTitle,
          icon: AppIcons.addToCatalog,
          onPressed: () => TitleFormDialog.show(context),
        ),
        _QuickAction(
          label: l10n.dashboardAddMember,
          icon: AppIcons.addPerson,
          onPressed: () => MemberFormDialog.show(context),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final AppIconSpec icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      size: AppButtonSize.medium,
      variant: AppButtonVariant.outline,
      icon: icon,
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
