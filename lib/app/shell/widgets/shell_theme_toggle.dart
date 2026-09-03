import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/theme/cubit/theme_cubit.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Cycles system → light → dark from a single control.
///
/// Lives at the foot of the rail with the rest of the app-wide chrome, not
/// in a settings screen: it is the one visible, working piece of state the
/// scaffold has before any feature exists — flipping it proves theming,
/// persistence, and the bloc wiring in one gesture.
class ShellThemeToggle extends StatelessWidget {
  const ShellThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => AppIconButton(
        tooltip: l10n.themeToggleTooltip,
        onPressed: () => context.read<ThemeCubit>().cycleThemeMode(),
        icon: switch (mode) {
          ThemeMode.system => AppIcons.systemMode,
          ThemeMode.light => AppIcons.lightMode,
          ThemeMode.dark => AppIcons.darkMode,
        },
      ),
    );
  }
}
