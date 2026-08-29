import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// {@template app_colors}
/// Custom color tokens beyond Material's [ColorScheme].
///
/// Only roles Material does not provide: success, warning, info,
/// high-emphasis text, deep brand, and the paper reading surface. Do not
/// mirror primary or surface — those already have Material roles.
/// {@endtemplate}
class AppColors extends ThemeExtension<AppColors> {
  /// {@macro app_colors}
  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.onInfo,
    required this.textHigh,
    required this.brandDeep,
    required this.paper,
    required this.paperElevated,
    required this.onPaper,
  });

  /// Light-mode semantic colors, sourced from [AppPalette].
  factory AppColors.light() => const AppColors(
    success: AppPalette.successLight,
    onSuccess: AppPalette.onSuccessLight,
    warning: AppPalette.warningLight,
    onWarning: AppPalette.onWarningLight,
    info: AppPalette.infoLight,
    onInfo: AppPalette.onInfoLight,
    textHigh: AppPalette.textHighLight,
    brandDeep: AppPalette.brandDeepLight,
    paper: AppPalette.paper,
    paperElevated: AppPalette.paperElevated,
    onPaper: AppPalette.onPaper,
  );

  /// Dark-mode semantic colors, sourced from [AppPalette].
  factory AppColors.dark() => const AppColors(
    success: AppPalette.successDark,
    onSuccess: AppPalette.onSuccessDark,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.onWarningDark,
    info: AppPalette.infoDark,
    onInfo: AppPalette.onInfoDark,
    textHigh: AppPalette.textHighDark,
    brandDeep: AppPalette.brandDeepDark,
    paper: AppPalette.paper,
    paperElevated: AppPalette.paperElevated,
    onPaper: AppPalette.onPaper,
  );

  /// The color used for success states — returned on time, available, active.
  final Color success;

  /// The color used for content on top of [success].
  final Color onSuccess;

  /// The color used for warning states — due soon, low stock, expiring.
  final Color warning;

  /// The color used for content on top of [warning].
  final Color onWarning;

  /// The color used for informational states — reserved, on hold, imported.
  final Color info;

  /// The color used for content on top of [info].
  final Color onInfo;

  /// High-emphasis text beyond [ColorScheme.onSurface].
  final Color textHigh;

  /// Deeper brand teal Material has no role for.
  final Color brandDeep;

  /// Warm parchment for long-form reading surfaces. Identical in both themes
  /// so a page reads as a material, not a themed background.
  final Color paper;

  /// Raised parchment, the light end of a [paper] gradient.
  final Color paperElevated;

  /// Content color on [paper] / [paperElevated].
  final Color onPaper;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? onInfo,
    Color? textHigh,
    Color? brandDeep,
    Color? paper,
    Color? paperElevated,
    Color? onPaper,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      textHigh: textHigh ?? this.textHigh,
      brandDeep: brandDeep ?? this.brandDeep,
      paper: paper ?? this.paper,
      paperElevated: paperElevated ?? this.paperElevated,
      onPaper: onPaper ?? this.onPaper,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      textHigh: Color.lerp(textHigh, other.textHigh, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      paperElevated: Color.lerp(paperElevated, other.paperElevated, t)!,
      onPaper: Color.lerp(onPaper, other.onPaper, t)!,
    );
  }
}
