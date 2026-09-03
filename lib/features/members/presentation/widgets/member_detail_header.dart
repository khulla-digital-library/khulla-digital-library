import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/placeholder/member_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/record_header.dart';
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

    return RecordHeader(
      title: member.name,
      initials: member.initials,
      facts: [member.cardNumber, member.category.label(l10n)],
      badges: [
        AppStatusBadge(
          label: member.status.label(l10n),
          tone: member.status.tone,
        ),
        if (member.finesOwed.isPositive)
          AppStatusBadge(
            label: l10n.memberDetailOwes(member.finesOwed.display()),
            tone: AppStatusTone.danger,
          ),
      ],
      note: member.notes,
      actions: [
        AppMenuButton(actions: menuActions, tooltip: l10n.commonMoreActions),
        SizedBox(width: spacing.xs),
        AppButton(
          size: AppButtonSize.medium,
          onPressed: onCheckOut,
          child: Text(l10n.circulationCheckOut),
        ),
      ],
    );
  }
}
