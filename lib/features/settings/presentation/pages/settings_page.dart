import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/settings_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/components/navigation_tile.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The index of everything configurable about this installation.
///
/// Five doors and one card. The card is *About*, which has nowhere to go —
/// it is three read-only facts, and a page holding only those would be a
/// click for nothing.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                CollectionHeader(
                  title: l10n.settingsHeading,
                  subtitle: l10n.settingsSubtitle,
                ),
                SizedBox(height: spacing.lg),
                AppResponsiveGrid(
                  children: [
                    NavigationTile(
                      label: l10n.settingsLibraryTitle,
                      description: l10n.settingsLibraryBody,
                      icon: Icons.local_library_outlined,
                      route: Routes.settingsLibrary,
                    ),
                    NavigationTile(
                      label: l10n.settingsLoanRulesTitle,
                      description: l10n.settingsLoanRulesBody,
                      icon: Icons.rule_rounded,
                      route: Routes.settingsLoanRules,
                    ),
                    NavigationTile(
                      label: l10n.settingsAppearanceTitle,
                      description: l10n.settingsAppearanceBody,
                      icon: Icons.palette_outlined,
                      route: Routes.settingsAppearance,
                    ),
                    NavigationTile(
                      label: l10n.settingsBackupTitle,
                      description: l10n.settingsBackupBody,
                      icon: Icons.backup_outlined,
                      route: Routes.settingsBackup,
                    ),
                  ],
                ),
                SizedBox(height: spacing.lg),
                const _AboutCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Version, licence and where the catalogue lives on this machine.
///
/// The storage path matters more than it looks: this app holds a library's
/// only copy of its records, and an operator taking a backup by hand needs to
/// know which file to copy.
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return SectionCard(
      title: l10n.settingsAboutTitle,
      subtitle: l10n.settingsAboutBody,
      icon: Icons.info_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDetailRow(
            label: l10n.settingsAboutVersion,
            child: const Text(placeholderVersion),
          ),
          SizedBox(height: spacing.sm),
          AppDetailRow(
            label: l10n.settingsAboutStorage,
            child: const Text(placeholderStoragePath),
          ),
          SizedBox(height: spacing.sm),
          AppDetailRow(
            label: l10n.settingsAboutLicence,
            child: const Text(placeholderLicence),
          ),
        ],
      ),
    );
  }
}
