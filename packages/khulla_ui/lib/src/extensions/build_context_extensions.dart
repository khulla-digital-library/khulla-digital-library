import 'package:flutter/material.dart';
import 'package:khulla_ui/src/theme/app_breakpoints.dart';
import 'package:khulla_ui/src/theme/app_colors.dart';
import 'package:khulla_ui/src/theme/app_radius.dart';
import 'package:khulla_ui/src/theme/app_shadows.dart';
import 'package:khulla_ui/src/theme/app_spacing.dart';
import 'package:khulla_ui/src/theme/app_text_styles.dart';

/// Extension on [BuildContext] for design-system tokens.
extension AppThemeBuildContext on BuildContext {
  /// Ambient [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// Material [TextTheme] from the ambient theme.
  TextTheme get textTheme => theme.textTheme;

  /// Material [ColorScheme] from the ambient theme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Custom color tokens Material's [ColorScheme] does not provide.
  AppColors get appColors => theme.extension<AppColors>()!;

  /// The package's spacing scale.
  AppSpacing get appSpacing => theme.extension<AppSpacing>()!;

  /// The package's corner-radius scale.
  AppRadius get appRadius => theme.extension<AppRadius>()!;

  /// The elevation tokens — `card`, `raised`, `overlay`.
  AppShadows get appShadows => theme.extension<AppShadows>()!;

  /// Window size class thresholds and content caps.
  AppBreakpoints get appBreakpoints => theme.extension<AppBreakpoints>()!;

  /// Extra text styles beyond [ThemeData].
  AppTextStyles get appTextStyles => theme.extension<AppTextStyles>()!;

  /// Window size class from [MediaQuery] width.
  ///
  /// Use for page-level structure. Inside a component that must adapt to
  /// its slot, use [LayoutBuilder] instead.
  FormFactor get formFactor {
    final width = MediaQuery.sizeOf(this).width;
    return appBreakpoints.formFactorFor(width);
  }
}
