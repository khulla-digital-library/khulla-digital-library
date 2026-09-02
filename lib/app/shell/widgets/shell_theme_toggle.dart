import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/theme/cubit/theme_cubit.dart';
import 'package:khulla/l10n/l10n.dart';

/// Cycles system → light → dark from a single control.
///
/// Lives in the shell rather than a settings screen so the scaffold has one
/// visible, working piece of state before any feature exists — flipping it
/// proves theming, persistence, and the bloc wiring in one gesture.
class ShellThemeToggle extends StatelessWidget {
  const ShellThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) => IconButton(
        tooltip: l10n.themeToggleTooltip,
        onPressed: () => context.read<ThemeCubit>().cycleThemeMode(),
        icon: Icon(switch (mode) {
          ThemeMode.system => Icons.brightness_auto_outlined,
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
        }),
      ),
    );
  }
}
