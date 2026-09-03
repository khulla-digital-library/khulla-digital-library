import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/core/theme/cubit/theme_cubit.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The one settings screen that is not a placeholder.
///
/// [ThemeCubit] is an app-wide `@lazySingleton` with real storage behind it,
/// so the choice made here survives a restart. It is a device setting, not a
/// library one — nothing about it reaches the catalogue file.
/// The language the interface is drawn in.
enum AppLanguage { english, nepali }

/// How much room a table row takes.
enum RowDensity { comfortable, compact }

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  AppLanguage _language = AppLanguage.english;
  RowDensity _density = RowDensity.comfortable;

  String _label(AppLocalizations l10n, ThemeMode mode) => switch (mode) {
    ThemeMode.system => l10n.themeModeSystem,
    ThemeMode.light => l10n.themeModeLight,
    ThemeMode.dark => l10n.themeModeDark,
  };

  AppIconSpec _icon(ThemeMode mode) => switch (mode) {
    ThemeMode.system => AppIcons.systemMode,
    ThemeMode.light => AppIcons.lightMode,
    ThemeMode.dark => AppIcons.darkMode,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AppPageBody(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.page,
          spacing.lg,
          spacing.page,
          spacing.xlg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: l10n.settingsAppearanceTitle,
              onBackPressed: () => context.go(Routes.settings),
            ),
            SizedBox(height: spacing.lg),
            SectionCard(
              title: l10n.settingsAppearanceTheme,
              subtitle: l10n.settingsAppearanceThemeDescription,
              child: BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => Align(
                  alignment: Alignment.centerLeft,
                  child: AppSegmentedControl<ThemeMode>(
                    value: mode,
                    items: ThemeMode.values,
                    itemLabel: (value) => _label(l10n, value),
                    itemIcon: _icon,
                    onChanged: (value) =>
                        context.read<ThemeCubit>().setThemeMode(value),
                  ),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            SectionCard(
              title: l10n.settingsAppearanceLanguage,
              subtitle: l10n.settingsAppearanceLanguageDescription,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppSegmentedControl<AppLanguage>(
                  value: _language,
                  items: AppLanguage.values,
                  itemLabel: (value) => switch (value) {
                    AppLanguage.english => l10n.settingsLanguageEnglish,
                    AppLanguage.nepali => l10n.settingsLanguageNepali,
                  },
                  onChanged: (value) => setState(() => _language = value),
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            SectionCard(
              title: l10n.settingsAppearanceDensity,
              subtitle: l10n.settingsAppearanceDensityDescription,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppSegmentedControl<RowDensity>(
                  value: _density,
                  items: RowDensity.values,
                  itemLabel: (value) => switch (value) {
                    RowDensity.comfortable => l10n.settingsDensityComfortable,
                    RowDensity.compact => l10n.settingsDensityCompact,
                  },
                  onChanged: (value) => setState(() => _density = value),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
