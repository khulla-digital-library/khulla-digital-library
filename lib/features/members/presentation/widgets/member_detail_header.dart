import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/placeholder/member_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A borrower's identity block: who they are, how their card stands, and the
/// action the desk came here for.
///
/// Checking out to this member is the primary action rather than *Edit*: the
/// register is opened at a counter far more often than it is corrected.
class MemberDetailHeader extends StatelessWidget {
  const MemberDetailHeader({
    required this.member,
    required this.onCheckOut,
    required this.menuActions,
    super.key,
  });

  final MemberRecord member;
  final VoidCallback onCheckOut;
  final List<AppMenuAction> menuActions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(initials: member.initials, size: 56),
        SizedBox(width: spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.name,
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.5,
                  color: context.appColors.textHigh,
                ),
              ),
              SizedBox(height: spacing.xs),
              Wrap(
                spacing: spacing.xs,
                runSpacing: spacing.xs,
                children: [
                  AppStatusBadge(
                    label: member.status.label(l10n),
                    tone: member.status.tone,
                  ),
                  AppStatusBadge(
                    label: member.category.label(l10n),
                    icon: member.category.icon,
                  ),
                  AppStatusBadge(
                    label: member.cardNumber,
                    icon: Icons.badge_outlined,
                  ),
                  if (member.finesOwed.isPositive)
                    AppStatusBadge(
                      label: member.finesOwed.display(),
                      tone: AppStatusTone.danger,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                ],
              ),
              if (member.notes case final notes?) ...[
                SizedBox(height: spacing.sm),
                Text(
                  notes,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    final actions = [
      AppMenuButton(actions: menuActions, tooltip: l10n.commonMoreActions),
      SizedBox(width: spacing.xs),
      AppButton(
        size: AppButtonSize.medium,
        onPressed: onCheckOut,
        child: Text(l10n.circulationCheckOut),
      ),
    ];

    return AppCard(
      child: context.formFactor.isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                identity,
                SizedBox(height: spacing.md),
                Row(children: actions),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: identity),
                SizedBox(width: spacing.lg),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
              ],
            ),
    );
  }
}
