import 'package:khulla/features/users/domain/user_role.dart';
import 'package:khulla/features/users/domain/user_status.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Localized names, tones and glyphs for the staff register's enums.
extension UserRoleX on UserRole {
  String label(AppLocalizations l10n) => switch (this) {
    UserRole.administrator => l10n.roleAdministrator,
    UserRole.librarian => l10n.roleLibrarian,
    UserRole.assistant => l10n.roleAssistant,
    UserRole.readOnly => l10n.roleReadOnly,
  };

  String description(AppLocalizations l10n) => switch (this) {
    UserRole.administrator => l10n.roleAdministratorBody,
    UserRole.librarian => l10n.roleLibrarianBody,
    UserRole.assistant => l10n.roleAssistantBody,
    UserRole.readOnly => l10n.roleReadOnlyBody,
  };

  AppStatusTone get tone => switch (this) {
    UserRole.administrator => AppStatusTone.brand,
    UserRole.librarian => AppStatusTone.info,
    UserRole.assistant => AppStatusTone.neutral,
    UserRole.readOnly => AppStatusTone.neutral,
  };

  IconData get icon => switch (this) {
    UserRole.administrator => Icons.admin_panel_settings_outlined,
    UserRole.librarian => Icons.local_library_outlined,
    UserRole.assistant => Icons.support_agent_outlined,
    UserRole.readOnly => Icons.visibility_outlined,
  };
}

extension UserStatusX on UserStatus {
  String label(AppLocalizations l10n) => switch (this) {
    UserStatus.active => l10n.usersStatusActive,
    UserStatus.invited => l10n.usersStatusInvited,
    UserStatus.disabled => l10n.usersStatusDisabled,
  };

  AppStatusTone get tone => switch (this) {
    UserStatus.active => AppStatusTone.success,
    UserStatus.invited => AppStatusTone.warning,
    UserStatus.disabled => AppStatusTone.neutral,
  };
}

extension StaffPermissionX on StaffPermission {
  String label(AppLocalizations l10n) => switch (this) {
    StaffPermission.catalog => l10n.permissionCatalog,
    StaffPermission.circulation => l10n.permissionCirculation,
    StaffPermission.members => l10n.permissionMembers,
    StaffPermission.fines => l10n.permissionFines,
    StaffPermission.reports => l10n.permissionReports,
    StaffPermission.settings => l10n.permissionSettings,
    StaffPermission.users => l10n.permissionUsers,
    StaffPermission.backup => l10n.permissionBackup,
  };
}
