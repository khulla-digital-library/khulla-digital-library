import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_responsive_theme}
/// Re-applies [AppTheme] when the window size class changes.
///
/// Wire once in `MaterialApp.builder`. Compact uses the mobile type ramp;
/// medium and expanded use the desktop ramp.
/// {@endtemplate}
class AppResponsiveTheme extends StatelessWidget {
  /// {@macro app_responsive_theme}
  const AppResponsiveTheme({required this.child, super.key});

  /// The subtree that inherits the form-factor theme.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final formFactor = context.formFactor;
    final brightness = context.theme.brightness;
    final theme = brightness == Brightness.dark
        ? AppTheme.dark(formFactor)
        : AppTheme.light(formFactor);
    return Theme(data: theme, child: child);
  }
}
