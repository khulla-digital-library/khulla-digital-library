import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Membership and contact fields the detail header does not repeat.
///
/// Two [SectionCard]s — membership (card, category, standing, dates) and
/// contact — rendered from ready-made strings.
class MemberDetailsCard extends StatelessWidget {
  const MemberDetailsCard({required this.member, super.key});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final notSet = l10n.commonNotSet;
    final dateOfBirth = member.dateOfBirth == null
        ? notSet
        : AppDateFormat.format(member.dateOfBirth!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SectionCard(
          title: l10n.memberDetailMembership,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, row) in <(String, String)>[
                (l10n.fieldCardNumber, member.cardNumber),
                (l10n.fieldCategory, member.memberTypeName),
                (l10n.commonStatus, member.status.label(l10n)),
                (l10n.fieldJoined, member.joined),
                (
                  l10n.fieldExpires,
                  member.expires.isEmpty ? notSet : member.expires,
                ),
                (l10n.fieldDateOfBirth, dateOfBirth),
                (l10n.fieldGuardian, member.guardian ?? notSet),
              ].indexed) ...[
                if (index > 0) SizedBox(height: spacing.sm),
                AppDetailRow(label: row.$1, child: Text(row.$2)),
              ],
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        SectionCard(
          title: l10n.memberDetailContact,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, row) in <(String, String)>[
                (l10n.fieldEmail, member.email ?? notSet),
                (l10n.fieldPhone, member.phone ?? notSet),
                (l10n.fieldAddress, member.address ?? notSet),
              ].indexed) ...[
                if (index > 0) SizedBox(height: spacing.sm),
                AppDetailRow(label: row.$1, child: Text(row.$2)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The four figures a desk decides on — copies out, how many are late, what
/// is owed, and lifetime borrowings.
class MemberDetailStats extends StatelessWidget {
  const MemberDetailStats({required this.member, super.key});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppStatStrip(
      tiles: [
        AppStatTile(
          label: l10n.memberDetailStatLoans,
          value: '${member.loansOut}',
          icon: AppIcons.transfer,
          tone: AppStatusTone.brand,
        ),
        AppStatTile(
          label: l10n.memberDetailStatOverdue,
          value: '${member.overdueLoans}',
          icon: AppIcons.error,
          tone: member.overdueLoans > 0
              ? AppStatusTone.danger
              : AppStatusTone.neutral,
        ),
        AppStatTile(
          label: l10n.memberDetailStatFines,
          value: member.finesOwed.display(),
          icon: AppIcons.wallet,
          tone: member.finesOwed.isPositive
              ? AppStatusTone.danger
              : AppStatusTone.neutral,
        ),
        AppStatTile(
          label: l10n.memberDetailStatBorrowed,
          value: '${member.borrowedAllTime}',
          icon: AppIcons.book,
        ),
      ],
    );
  }
}
