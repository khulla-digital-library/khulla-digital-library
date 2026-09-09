import 'package:khulla/features/members/domain/member_status.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Localized names and semantic tones for the register's enums.
extension MemberStatusX on MemberStatus {
  String label(AppLocalizations l10n) => switch (this) {
    MemberStatus.active => l10n.membersStatusActive,
    MemberStatus.expiring => l10n.membersStatusExpiring,
    MemberStatus.expired => l10n.membersStatusExpired,
    MemberStatus.suspended => l10n.membersStatusSuspended,
  };

  AppStatusTone get tone => switch (this) {
    MemberStatus.active => AppStatusTone.success,
    MemberStatus.expiring => AppStatusTone.warning,
    MemberStatus.expired => AppStatusTone.neutral,
    MemberStatus.suspended => AppStatusTone.danger,
  };
}

extension MemberTypeCodeX on String? {
  AppIconSpec get memberTypeIcon => switch (this) {
    'student' => AppIcons.education,
    'teacher' => AppIcons.teacher,
    'child' => AppIcons.child,
    _ => AppIcons.person,
  };
}
