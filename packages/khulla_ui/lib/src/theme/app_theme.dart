import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';
import 'package:khulla_ui/src/theme/app_fonts.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// The app's two themes, built per window size class.
///
/// Two things change with the window and nothing else does: the type ramp
/// (a phone reads a smaller title than a 27" monitor) and visual density (a
/// pointer fits more rows per screen than a thumb). Colors, radii and spacing
/// are identical at every width — a component must not change *what it is*
/// when the window resizes, only how much room it takes.
abstract final class AppTheme {
  /// The light theme for [formFactor].
  static ThemeData light([FormFactor formFactor = FormFactor.compact]) =>
      _themeFrom(Brightness.light, formFactor);

  /// The dark theme for [formFactor].
  static ThemeData dark([FormFactor formFactor = FormFactor.compact]) =>
      _themeFrom(Brightness.dark, formFactor);

  static ThemeData _themeFrom(Brightness brightness, FormFactor formFactor) {
    final colorScheme = _brandColorScheme(brightness);
    final isLight = brightness == Brightness.light;
    final appColors = isLight ? AppColors.light() : AppColors.dark();
    final shadows = isLight ? AppShadows.light() : AppShadows.dark();
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
    final pillShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius.bar),
    );

    // The canvas is pure white in light mode; `surface` still carries the
    // same value, so cards define themselves with a hairline border rather
    // than by contrasting fill. Dark mode keeps its darker canvas — a card
    // there is still lighter than the page, so fill alone reads as raised.
    final canvas = isLight ? AppPalette.surfaceLight : AppPalette.canvasDark;
    final chromeBg = colorScheme.surface;
    final subtle = isLight
        ? AppPalette.surfaceSubtleLight
        : AppPalette.surfaceSubtleDark;

    final buttonLabel = textTheme.labelLarge?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
    );

    InputBorder fieldBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius.field),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.lexend,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      splashFactory: InkSparkle.splashFactory,
      // A pointer-driven window fits more rows per screen than a thumb does.
      visualDensity: formFactor.isCompact
          ? VisualDensity.standard
          : VisualDensity.comfortable,
      extensions: <ThemeExtension<dynamic>>[
        appColors,
        spacing,
        radius,
        breakpoints,
        shadows,
        const AppTextStyles(),
      ],
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 20),
      appBarTheme: AppBarTheme(
        backgroundColor: chromeBg,
        foregroundColor: colorScheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: appColors.textHigh,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: AppButtonInteraction.filled(
          FilledButton.styleFrom(
            minimumSize: Size(0, spacing.xlg + spacing.sm), // 44
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md + spacing.xxs,
              vertical: spacing.xs,
            ),
            textStyle: buttonLabel,
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
            foregroundColor: appColors.textHigh,
            backgroundColor: colorScheme.surface,
            side: BorderSide(color: appColors.hairlineStrong),
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.xs + 2,
            ),
            textStyle: buttonLabel,
            shape: buttonShape,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: AppButtonInteraction.text(
          TextButton.styleFrom(
            foregroundColor: colorScheme.primary,
            textStyle: buttonLabel,
            shape: buttonShape,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: pillShape,
        side: BorderSide.none,
        backgroundColor: subtle,
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
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        border: fieldBorder(appColors.hairlineStrong),
        enabledBorder: fieldBorder(appColors.hairlineStrong),
        disabledBorder: fieldBorder(appColors.hairline),
        focusedBorder: fieldBorder(colorScheme.primary, 1.5),
        errorBorder: fieldBorder(colorScheme.error),
        focusedErrorBorder: fieldBorder(colorScheme.error, 1.5),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacing.sm + 2,
          vertical: spacing.sm,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: appColors.textMuted),
        helperStyle: textTheme.bodySmall?.copyWith(color: appColors.textMuted),
        errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        prefixIconColor: appColors.textMuted,
        suffixIconColor: appColors.textMuted,
      ),
      cardTheme: CardThemeData(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: cardShape,
        elevation: 0,
        color: chromeBg,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: chromeBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.card),
          side: BorderSide(color: appColors.hairline),
        ),
        textStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: chromeBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.banner),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: appColors.textHigh,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: chromeBg,
        indicatorColor: appColors.brandSoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary, size: 22);
          }
          return IconThemeData(color: appColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
          );
          if (states.contains(WidgetState.selected)) {
            return base?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base?.copyWith(color: appColors.textMuted);
        }),
        elevation: 0,
        height: 64,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: chromeBg,
        indicatorColor: appColors.brandSoft,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.tile),
        ),
        selectedIconTheme: IconThemeData(color: colorScheme.primary, size: 22),
        unselectedIconTheme: IconThemeData(
          color: appColors.textMuted,
          size: 22,
        ),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: appColors.textMuted,
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
            top: Radius.circular(radius.banner),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: appColors.hairline,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius.badge),
        ),
        side: BorderSide(color: appColors.hairlineStrong, width: 1.5),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: subtle,
        circularTrackColor: subtle,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: appColors.textMuted,
        indicatorColor: colorScheme.primary,
        dividerColor: appColors.hairline,
        labelStyle: textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
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
            return base.withValues(alpha: 0.4);
          }
          if (states.contains(WidgetState.hovered)) {
            return base.withValues(alpha: 0.28);
          }
          return base.withValues(alpha: 0.14);
        }),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
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
        primaryContainer: AppPalette.brandSoftLight,
        onPrimaryContainer: AppPalette.brandDeepLight,
        secondary: AppPalette.textHighLight,
        onSecondary: AppPalette.surfaceLight,
        secondaryContainer: AppPalette.surfaceSubtleLight,
        onSecondaryContainer: AppPalette.textHighLight,
        tertiary: AppPalette.brandDeepLight,
        onTertiary: AppPalette.surfaceLight,
        tertiaryContainer: AppPalette.brandSoftLight,
        onTertiaryContainer: AppPalette.brandDeepLight,
        error: AppPalette.dangerLight,
        onError: AppPalette.onDangerLight,
        errorContainer: AppPalette.dangerSoftLight,
        onErrorContainer: AppPalette.dangerLight,
        surface: AppPalette.surfaceLight,
        onSurface: AppPalette.textBodyLight,
        onSurfaceVariant: AppPalette.textMutedLight,
        surfaceContainerLowest: AppPalette.surfaceLight,
        surfaceContainerLow: AppPalette.surfaceSubtleLight,
        surfaceContainer: AppPalette.surfaceSubtleLight,
        surfaceContainerHigh: AppPalette.surfaceMutedLight,
        surfaceContainerHighest: AppPalette.surfaceMutedLight,
        surfaceTint: Colors.transparent,
        outline: AppPalette.outlineStrongLight,
        outlineVariant: AppPalette.outlineLight,
        shadow: AppPalette.shadowLight,
        inverseSurface: AppPalette.textHighLight,
        onInverseSurface: AppPalette.surfaceLight,
      );
    }

    return seeded.copyWith(
      primary: AppPalette.brandSeed,
      onPrimary: AppPalette.surfaceLight,
      primaryContainer: AppPalette.brandSoftDark,
      onPrimaryContainer: AppPalette.brandDeepDark,
      secondary: AppPalette.textHighDark,
      onSecondary: AppPalette.canvasDark,
      secondaryContainer: AppPalette.surfaceMutedDark,
      onSecondaryContainer: AppPalette.textHighDark,
      tertiary: AppPalette.brandDeepDark,
      onTertiary: AppPalette.canvasDark,
      tertiaryContainer: AppPalette.brandSoftDark,
      onTertiaryContainer: AppPalette.brandDeepDark,
      error: AppPalette.dangerDark,
      onError: AppPalette.onDangerDark,
      errorContainer: AppPalette.dangerSoftDark,
      onErrorContainer: AppPalette.dangerDark,
      surface: AppPalette.surfaceDark,
      onSurface: AppPalette.textBodyDark,
      onSurfaceVariant: AppPalette.textMutedDark,
      surfaceContainerLowest: AppPalette.canvasDark,
      surfaceContainerLow: AppPalette.surfaceSubtleDark,
      surfaceContainer: AppPalette.surfaceSubtleDark,
      surfaceContainerHigh: AppPalette.surfaceMutedDark,
      surfaceContainerHighest: AppPalette.surfaceMutedDark,
      surfaceTint: Colors.transparent,
      outline: AppPalette.outlineStrongDark,
      outlineVariant: AppPalette.outlineDark,
      shadow: AppPalette.shadowDark,
      inverseSurface: AppPalette.textHighDark,
      onInverseSurface: AppPalette.canvasDark,
    );
  }
}
