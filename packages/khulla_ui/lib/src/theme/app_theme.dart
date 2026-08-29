import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';
import 'package:khulla_ui/src/theme/app_fonts.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// {@template app_theme}
/// Composes [ThemeData] with [ColorScheme.fromSeed], the form-factor type
/// ramp, component themes, and custom [ThemeExtension]s.
/// {@endtemplate}
abstract final class AppTheme {
  /// Light [ThemeData] for the given [formFactor].
  ///
  /// Compact uses the mobile type ramp; every wider class uses the desktop
  /// ramp and a denser [VisualDensity].
  static ThemeData light([FormFactor formFactor = FormFactor.compact]) =>
      _themeFrom(Brightness.light, formFactor);

  /// Dark [ThemeData] for the given [formFactor].
  static ThemeData dark([FormFactor formFactor = FormFactor.compact]) =>
      _themeFrom(Brightness.dark, formFactor);

  static ThemeData _themeFrom(Brightness brightness, FormFactor formFactor) {
    final colorScheme = _brandColorScheme(brightness);
    final isLight = brightness == Brightness.light;
    final appColors = isLight ? AppColors.light() : AppColors.dark();
    const spacing = AppSpacing();
    const radius = AppRadius();
    const breakpoints = AppBreakpoints();
    final textTheme = formFactor.isCompact
        ? AppTextStyles.mobileTextTheme
        : AppTextStyles.desktopTextTheme;

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.card),
    );
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.control),
    );
    // Pill shape for chips and tags; standard shape for cards/buttons.
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.bar),
    );

    final scaffoldBg = isLight
        ? AppPalette.surfaceMutedLight
        : AppPalette.surfaceDark;
    final chromeBg = isLight
        ? AppPalette.surfaceLight
        : colorScheme.surfaceContainerLow;

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.lexend,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scaffoldBg,
      // A pointer-driven window fits more rows per screen than a thumb does.
      visualDensity: formFactor.isCompact
          ? VisualDensity.standard
          : VisualDensity.comfortable,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
        spacing,
        radius,
        breakpoints,
        const AppTextStyles(),
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: chromeBg,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.35,
          fontSize: (textTheme.titleLarge?.fontSize ?? 20) + 1,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonInteraction.filled(
          FilledButton.styleFrom(
            minimumSize: Size(0, spacing.xlg + spacing.sm), // 44
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs,
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            shape: buttonShape,
            elevation: 0,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: AppButtonInteraction.outlined(
          OutlinedButton.styleFrom(
            minimumSize: Size(0, spacing.xlg + spacing.sm), // 44
            foregroundColor: colorScheme.primary,
            side: BorderSide(color: colorScheme.primary, width: 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs + 2,
            ),
            textStyle: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            shape: buttonShape,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonInteraction.text(
          TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            textStyle: textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: pillShape,
        side: BorderSide.none,
        labelStyle: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w500),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: buttonShape,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.xs + 2,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: cardShape,
        elevation: 0,
        color: chromeBg,
        surfaceTintColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: chromeBg,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 24);
          }
          return IconThemeData(
            color: colorScheme.onSurface.withValues(alpha: 0.55),
            size: 24,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          );
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(color: colorScheme.primary);
          }
          return base?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.55),
          );
        }),
        elevation: 0,
        height: 64,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: chromeBg,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.12),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.tile),
        ),
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          size: 22,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          fontWeight: FontWeight.w400,
        ),
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: chromeBg,
        modalBackgroundColor: chromeBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radius.banner - radius.badge),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.5),
        indicatorColor: colorScheme.primary,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      // A desktop window has no fling gesture to reveal a scrollbar, so the
      // thumb stays visible wherever a pointer is the primary input.
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStatePropertyAll(formFactor.isWide),
        thickness: const WidgetStatePropertyAll(8),
        radius: Radius.circular(radius.pill),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          final base = colorScheme.onSurface;
          if (states.contains(WidgetState.dragged)) {
            return base.withValues(alpha: 0.45);
          }
          if (states.contains(WidgetState.hovered)) {
            return base.withValues(alpha: 0.32);
          }
          return base.withValues(alpha: 0.18);
        }),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(radius.badge + 2),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xs,
          vertical: spacing.xxs + 1,
        ),
        textStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),
    );
  }

  /// Brand teal on cool-neutral surfaces.
  ///
  /// Unlike a consumer app that keeps chrome monochrome and spends its brand
  /// color only on CTAs, a catalogue tool leans on Material's own primary
  /// role — selection, focus rings, switches, progress, and the navigation
  /// indicator all inherit the brand without per-widget overrides.
  static ColorScheme _brandColorScheme(Brightness brightness) {
    final seeded = ColorScheme.fromSeed(
      seedColor: AppPalette.brandSeed,
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.neutral,
    );

    if (brightness == Brightness.light) {
      return seeded.copyWith(
        primary: AppPalette.brandSeed,
        onPrimary: AppPalette.surfaceLight,
        primaryContainer: AppPalette.surfaceMutedLight,
        onPrimaryContainer: AppPalette.brandDeepLight,
        secondary: AppPalette.textHighLight,
        onSecondary: AppPalette.surfaceLight,
        secondaryContainer: AppPalette.surfaceMutedLight,
        onSecondaryContainer: AppPalette.textHighLight,
        tertiary: AppPalette.brandDeepLight,
        onTertiary: AppPalette.surfaceLight,
        tertiaryContainer: AppPalette.surfaceMutedLight,
        onTertiaryContainer: AppPalette.brandDeepLight,
        surface: AppPalette.surfaceLight,
        onSurface: AppPalette.textHighLight,
        surfaceContainerLowest: AppPalette.surfaceLight,
        surfaceContainerLow: AppPalette.surfaceLight,
        surfaceContainer: AppPalette.surfaceMutedLight,
        surfaceContainerHigh: AppPalette.surfaceMutedLight,
        surfaceContainerHighest: AppPalette.surfaceMutedLight,
        surfaceTint: Colors.transparent,
        outline: AppPalette.outlineLight,
        outlineVariant: AppPalette.outlineLight,
      );
    }

    return seeded.copyWith(
      primary: AppPalette.brandDeepDark,
      onPrimary: AppPalette.surfaceDark,
      primaryContainer: AppPalette.surfaceMutedDark,
      onPrimaryContainer: AppPalette.brandDeepDark,
      secondary: AppPalette.textHighDark,
      onSecondary: AppPalette.surfaceDark,
      secondaryContainer: AppPalette.surfaceMutedDark,
      onSecondaryContainer: AppPalette.textHighDark,
      tertiary: AppPalette.brandSeed,
      onTertiary: AppPalette.textHighDark,
      tertiaryContainer: AppPalette.surfaceMutedDark,
      onTertiaryContainer: AppPalette.brandDeepDark,
      surface: AppPalette.surfaceDark,
      onSurface: AppPalette.textHighDark,
      surfaceContainerLowest: AppPalette.surfaceDark,
      surfaceContainerLow: AppPalette.surfaceMutedDark,
      surfaceContainer: AppPalette.surfaceMutedDark,
      surfaceContainerHigh: AppPalette.surfaceMutedDark,
      surfaceContainerHighest: AppPalette.surfaceMutedDark,
      surfaceTint: Colors.transparent,
      outline: AppPalette.outlineDark,
      outlineVariant: AppPalette.outlineDark,
    );
  }
}
