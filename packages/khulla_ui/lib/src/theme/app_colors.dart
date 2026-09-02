import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// Semantic colors Material's [ColorScheme] has no role for.
///
/// Every token here answers a question the scheme cannot: *is this loan
/// overdue*, *is this member active*, *is this copy reserved*. Roles the
/// scheme already owns — primary, surface, error — are never mirrored here.
///
/// Each status carries three values: the ink (`success`), the ink's contrast
/// (`onSuccess`, for a solid fill) and the wash (`successSoft`, the tint a
/// badge or an icon chip sits on). Deriving the wash by blending the ink into
/// the surface is what makes a badge look muddy in dark mode; these are
/// hand-picked per brightness instead.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.success,
    required this.onSuccess,
    required this.successSoft,
    required this.warning,
    required this.onWarning,
    required this.warningSoft,
    required this.info,
    required this.onInfo,
    required this.infoSoft,
    required this.danger,
    required this.onDanger,
    required this.dangerSoft,
    required this.neutralSoft,
    required this.brandSoft,
    required this.brandStrong,
    required this.textHigh,
    required this.textMuted,
    required this.brandDeep,
    required this.hairline,
    required this.hairlineStrong,
    required this.paper,
    required this.paperElevated,
    required this.onPaper,
  });

  /// The light palette.
  factory AppColors.light() => const AppColors(
    success: AppPalette.successLight,
    onSuccess: AppPalette.onSuccessLight,
    successSoft: AppPalette.successSoftLight,
    warning: AppPalette.warningLight,
    onWarning: AppPalette.onWarningLight,
    warningSoft: AppPalette.warningSoftLight,
    info: AppPalette.infoLight,
    onInfo: AppPalette.onInfoLight,
    infoSoft: AppPalette.infoSoftLight,
    danger: AppPalette.dangerLight,
    onDanger: AppPalette.onDangerLight,
    dangerSoft: AppPalette.dangerSoftLight,
    neutralSoft: AppPalette.neutralSoftLight,
    brandSoft: AppPalette.brandSoftLight,
    brandStrong: AppPalette.brandStrongLight,
    textHigh: AppPalette.textHighLight,
    textMuted: AppPalette.textMutedLight,
    brandDeep: AppPalette.brandDeepLight,
    hairline: AppPalette.outlineLight,
    hairlineStrong: AppPalette.outlineStrongLight,
    paper: AppPalette.paper,
    paperElevated: AppPalette.paperElevated,
    onPaper: AppPalette.onPaper,
  );

  /// The dark palette.
  factory AppColors.dark() => const AppColors(
    success: AppPalette.successDark,
    onSuccess: AppPalette.onSuccessDark,
    successSoft: AppPalette.successSoftDark,
    warning: AppPalette.warningDark,
    onWarning: AppPalette.onWarningDark,
    warningSoft: AppPalette.warningSoftDark,
    info: AppPalette.infoDark,
    onInfo: AppPalette.onInfoDark,
    infoSoft: AppPalette.infoSoftDark,
    danger: AppPalette.dangerDark,
    onDanger: AppPalette.onDangerDark,
    dangerSoft: AppPalette.dangerSoftDark,
    neutralSoft: AppPalette.neutralSoftDark,
    brandSoft: AppPalette.brandSoftDark,
    brandStrong: AppPalette.brandDeepDark,
    textHigh: AppPalette.textHighDark,
    textMuted: AppPalette.textMutedDark,
    brandDeep: AppPalette.brandDeepDark,
    hairline: AppPalette.outlineDark,
    hairlineStrong: AppPalette.outlineStrongDark,
    paper: AppPalette.paper,
    paperElevated: AppPalette.paperElevated,
    onPaper: AppPalette.onPaper,
  );

  /// Returned on time, available, active member.
  final Color success;

  /// Content on a solid [success] fill.
  final Color onSuccess;

  /// The wash a success badge or icon chip sits on.
  final Color successSoft;

  /// Due soon, last copy out, membership expiring.
  final Color warning;

  /// Content on a solid [warning] fill.
  final Color onWarning;

  /// The wash a warning badge sits on.
  final Color warningSoft;

  /// Reserved, on hold, imported.
  final Color info;

  /// Content on a solid [info] fill.
  final Color onInfo;

  /// The wash an info badge sits on.
  final Color infoSoft;

  /// Overdue, lost, destructive.
  final Color danger;

  /// Content on a solid [danger] fill.
  final Color onDanger;

  /// The wash a danger badge sits on.
  final Color dangerSoft;

  /// The wash an inert badge or a muted icon chip sits on.
  final Color neutralSoft;

  /// The wash behind an active rail item or a brand icon chip.
  final Color brandSoft;

  /// Hovered / pressed brand.
  final Color brandStrong;

  /// High-emphasis text that sits above `onSurface` — a page title, a figure.
  final Color textHigh;

  /// Secondary and supporting text.
  final Color textMuted;

  /// Deeper brand for emphasis text and ink ripples.
  final Color brandDeep;

  /// The hairline every card, row and section is separated by.
  final Color hairline;

  /// The hairline one step stronger, for field borders.
  final Color hairlineStrong;

  /// Long-form reading surface. Theme-invariant on purpose.
  final Color paper;

  /// The raised end of a [paper] surface.
  final Color paperElevated;

  /// Content on [paper]. Never pair `onSurface` with [paper].
  final Color onPaper;

  @override
  AppColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successSoft,
    Color? warning,
    Color? onWarning,
    Color? warningSoft,
    Color? info,
    Color? onInfo,
    Color? infoSoft,
    Color? danger,
    Color? onDanger,
    Color? dangerSoft,
    Color? neutralSoft,
    Color? brandSoft,
    Color? brandStrong,
    Color? textHigh,
    Color? textMuted,
    Color? brandDeep,
    Color? hairline,
    Color? hairlineStrong,
    Color? paper,
    Color? paperElevated,
    Color? onPaper,
  }) {
    return AppColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successSoft: successSoft ?? this.successSoft,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningSoft: warningSoft ?? this.warningSoft,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoSoft: infoSoft ?? this.infoSoft,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      neutralSoft: neutralSoft ?? this.neutralSoft,
      brandSoft: brandSoft ?? this.brandSoft,
      brandStrong: brandStrong ?? this.brandStrong,
      textHigh: textHigh ?? this.textHigh,
      textMuted: textMuted ?? this.textMuted,
      brandDeep: brandDeep ?? this.brandDeep,
      hairline: hairline ?? this.hairline,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
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
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      neutralSoft: Color.lerp(neutralSoft, other.neutralSoft, t)!,
      brandSoft: Color.lerp(brandSoft, other.brandSoft, t)!,
      brandStrong: Color.lerp(brandStrong, other.brandStrong, t)!,
      textHigh: Color.lerp(textHigh, other.textHigh, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      paperElevated: Color.lerp(paperElevated, other.paperElevated, t)!,
      onPaper: Color.lerp(onPaper, other.onPaper, t)!,
    );
  }
}
