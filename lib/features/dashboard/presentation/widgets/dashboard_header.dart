import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The dashboard's title block and its single primary action.
///
/// One action, per the page recipe: everything else a shift starts with is a
/// quick-action tile further down, not a fourth button competing here.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final stacked = context.formFactor.isCompact;

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.dashboardTitle,
          style: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
            color: context.appColors.textHigh,
          ),
        ),
        SizedBox(height: spacing.xxs),
        Text(
          l10n.dashboardSubtitle,
          style: context.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );

    final action = AppButton(
      size: AppButtonSize.medium,
      onPressed: () => context.go(Routes.circulation),
      child: Text(l10n.dashboardCheckOut),
    );

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          title,
          SizedBox(height: spacing.md),
          action,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        SizedBox(width: spacing.lg),
        Padding(
          padding: EdgeInsets.only(top: spacing.xs),
          child: action,
        ),
      ],
    );
  }
}
