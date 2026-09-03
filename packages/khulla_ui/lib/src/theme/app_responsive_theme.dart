import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_responsive_theme}
/// Re-applies [AppTheme] when the window crosses the density step, and caps
/// text scaling.
///
/// Wire once in `MaterialApp.builder`. This is the **only** place the density
/// breakpoint is read: every paired token — type size, control height, icon
/// size, gap — is resolved from it inside the theme, so the whole screen
/// steps together rather than each widget consulting [MediaQuery] and
/// drifting out of step with its neighbours.
///
/// The scale cap is not optional. This design reads at 10–12px and lays out
/// 36px rows; unbounded scaling overflows a table row long before it helps
/// anyone, so it is clamped and the app offers density instead.
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
    final density = context.appBreakpoints.densityFor(media.size.width);
    final theme = context.theme.brightness == Brightness.dark
        ? AppTheme.dark(density)
        : AppTheme.light(density);

    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(maxScaleFactor: maxTextScale),
      ),
      child: Theme(data: theme, child: child),
    );
  }
}
