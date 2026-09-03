import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/settings_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/navigation_group.dart';
import 'package:khulla/shared/components/navigation_tile.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The index of everything configurable about this installation.
///
/// Five doors and one card. The doors are one list, not a grid of tiles: they
/// are alternatives to each other, and a shared frame with a hairline between
/// rows says that where five equal rectangles said the opposite. The card is
/// *About*, which has nowhere to go — three read-only facts, and a page
/// holding only those would be a click for nothing.
///
/// It takes the reading width rather than the wide cap. A settings index is
/// prose with links in it; stretched across a maximised window every row
/// becomes a label at one edge and a chevron a foot away at the other.
class SettingsPage extends StatelessWidget {
  const SettingsPage({this.showDesignSystem = false, super.key});

  /// Whether to offer the design-system gallery. The router passes the
  /// flavor's answer, so the door and the route it opens are gated on the
  /// same fact.
  final bool showDesignSystem;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AppPageBody(
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
                NavigationGroup(
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
                    NavigationTile(
                      label: l10n.settingsSyncTitle,
                      description: l10n.settingsSyncBody,
                      icon: Icons.cloud_sync_outlined,
                      route: Routes.settingsSync,
                    ),
                    if (showDesignSystem)
                      NavigationTile(
                        label: l10n.settingsDesignSystemTitle,
                        description: l10n.settingsDesignSystemBody,
                        icon: Icons.design_services_outlined,
                        route: Routes.settingsDesignSystem,
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
