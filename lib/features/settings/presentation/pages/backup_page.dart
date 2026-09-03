import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/settings_placeholder.dart';
import 'package:khulla/features/settings/presentation/widgets/settings_action_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Export, restore, import — and the one irreversible action in the app.
///
/// Khulla is local-first: there is no server holding a second copy of any of
/// this. That is why the erase action is fenced into its own card with its
/// own copy, and confirms through [AppDialog] with a button that names the
/// act rather than saying *OK*.
class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  Future<void> _confirmErase(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.settingsBackupEraseTitle,
      message: l10n.settingsBackupEraseBody,
      confirmLabel: l10n.settingsBackupEraseAction,
      cancelLabel: l10n.commonCancel,
      icon: Icons.warning_amber_rounded,
    );
    if (!context.mounted || !confirmed) return;
    showNotWiredToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverList.list(
              children: [
                AppPageHeader(
                  title: l10n.settingsBackupTitle,
                  onBackPressed: () => context.go(Routes.settings),
                ),
                SizedBox(height: spacing.lg),
                SectionCard(
                  title: l10n.settingsBackupTitle,
                  subtitle: l10n.settingsBackupBody,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppDetailRow(
                        label: l10n.settingsBackupLastBackup,
                        child: const Text(placeholderLastBackup),
                      ),
                      SizedBox(height: spacing.sm),
                      AppDetailRow(
                        label: l10n.settingsBackupDatabaseSize,
                        child: const Text(placeholderDatabaseSize),
                      ),
                      SizedBox(height: spacing.sm),
                      AppDetailRow(
                        label: l10n.settingsAboutStorage,
                        child: const Text(placeholderStoragePath),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
                AppResponsiveGrid(
                  largeColumns: 3,
                  children: [
                    SettingsActionCard(
                      title: l10n.settingsBackupExportTitle,
                      description: l10n.settingsBackupExportBody,
                      actionLabel: l10n.settingsBackupExportAction,
                      icon: Icons.file_download_outlined,
                      onAction: () => showNotWiredToast(context),
                    ),
                    SettingsActionCard(
                      title: l10n.settingsBackupRestoreTitle,
                      description: l10n.settingsBackupRestoreBody,
                      actionLabel: l10n.settingsBackupRestoreAction,
                      icon: Icons.restore_rounded,
                      onAction: () => showNotWiredToast(context),
                    ),
                    SettingsActionCard(
                      title: l10n.settingsBackupImportTitle,
                      description: l10n.settingsBackupImportBody,
                      actionLabel: l10n.settingsBackupImportAction,
                      icon: Icons.file_upload_outlined,
                      onAction: () => showNotWiredToast(context),
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                AppSectionHeader(
                  title: l10n.settingsBackupDangerTitle,
                  subtitle: l10n.settingsBackupDangerDescription,
                  icon: Icons.warning_amber_rounded,
                ),
                SizedBox(height: spacing.md),
                SettingsActionCard(
                  title: l10n.settingsBackupEraseTitle,
                  description: l10n.settingsBackupEraseBody,
                  actionLabel: l10n.settingsBackupEraseAction,
                  icon: Icons.delete_forever_outlined,
                  isDestructive: true,
                  onAction: () => unawaited(_confirmErase(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
