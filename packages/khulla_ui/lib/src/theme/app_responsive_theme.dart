import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_responsive_theme}
/// Clamps text scaling and re-applies [AppTheme] at the comfortable density
/// rung for the active brightness.
///
/// Wire once in `MaterialApp.builder`. Density does not change with window
/// width — only light/dark follows [ThemeMode].
///
/// The scale cap is not optional. Unbounded scaling overflows a table row
/// long before it helps anyone.
/// {@endtemplate}
class AppResponsiveTheme extends StatelessWidget {
  /// {@macro app_responsive_theme}
  const AppResponsiveTheme({required this.child, super.key});

  /// The subtree that inherits the resolved theme.
  final Widget child;

  /// The largest text scale the dense layouts survive.
  static const double maxTextScale = 1.3;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = context.theme.brightness == Brightness.dark
        ? AppTheme.dark()
        : AppTheme.light();

    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: maxTextScale),
      ),
      child: Theme(data: theme, child: child),
    );
  }
}
