import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
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
          icon: Icons.assignment_return_outlined,
          route: Routes.circulationReturn,
        ),
        _QuickAction(
          label: l10n.dashboardAddTitle,
          icon: Icons.library_add_outlined,
          route: Routes.catalogTitleNew,
        ),
        _QuickAction(
          label: l10n.dashboardAddMember,
          icon: Icons.person_add_alt_1_outlined,
          route: Routes.memberNew,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      size: AppButtonSize.medium,
      variant: AppButtonVariant.outline,
      icon: icon,
      onPressed: () => context.go(route),
      child: Text(label),
    );
  }
}
