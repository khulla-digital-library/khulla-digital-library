import 'package:khulla/features/members/domain/member_category.dart';
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

extension MemberCategoryX on MemberCategory {
  String label(AppLocalizations l10n) => switch (this) {
    MemberCategory.student => l10n.membersCategoryStudent,
    MemberCategory.teacher => l10n.membersCategoryTeacher,
    MemberCategory.public => l10n.membersCategoryPublic,
    MemberCategory.child => l10n.membersCategoryChild,
  };

  AppIconSpec get icon => switch (this) {
    MemberCategory.student => AppIcons.education,
    MemberCategory.teacher => AppIcons.teacher,
    MemberCategory.public => AppIcons.person,
    MemberCategory.child => AppIcons.child,
  };
}
