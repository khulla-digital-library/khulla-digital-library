import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/theme/cubit/theme_cubit.dart';
import 'package:khulla/core/theme/cubit/theme_state.dart';
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

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  AppLanguage _language = AppLanguage.english;

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

  String _brandLabel(AppLocalizations l10n, AppBrandTheme brand) =>
      switch (brand) {
        AppBrandTheme.teal => l10n.brandThemeTeal,
        AppBrandTheme.indigo => l10n.brandThemeIndigo,
        AppBrandTheme.blue => l10n.brandThemeBlue,
        AppBrandTheme.violet => l10n.brandThemeViolet,
        AppBrandTheme.rose => l10n.brandThemeRose,
        AppBrandTheme.amber => l10n.brandThemeAmber,
        AppBrandTheme.forest => l10n.brandThemeForest,
        AppBrandTheme.graphite => l10n.brandThemeGraphite,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AppPageBody(
      wide: true,
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
            BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, appearance) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionCard(
                    title: l10n.settingsAppearanceTheme,
                    subtitle: l10n.settingsAppearanceThemeDescription,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppSegmentedControl<ThemeMode>(
                        value: appearance.mode,
                        items: ThemeMode.values,
                        itemLabel: (value) => _label(l10n, value),
                        itemIcon: _icon,
                        onChanged: (value) =>
                            context.read<ThemeCubit>().setThemeMode(value),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing.md),
                  SectionCard(
                    title: l10n.settingsAppearanceBrand,
                    subtitle: l10n.settingsAppearanceBrandDescription,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppSwatchPicker<AppBrandTheme>(
                        value: appearance.brandTheme,
                        items: AppBrandTheme.values,
                        itemColor: (value) => value.seed,
                        itemLabel: (value) => _brandLabel(l10n, value),
                        onChanged: (value) =>
                            context.read<ThemeCubit>().setBrandTheme(value),
                      ),
                    ),
                  ),
                ],
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
          ],
        ),
      ),
    );
  }
}
