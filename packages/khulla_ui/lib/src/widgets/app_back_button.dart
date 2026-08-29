import 'package:khulla_ui/khulla_ui.dart';

/// Squircle back control used across nested and auth screens.
///
/// Use [AppBackButton] in page bodies; use [AppBackButton.leading] as
/// [AppBar.leading] so the control sits correctly in the Material slot.
class AppBackButton extends StatelessWidget {
  /// Standalone back control (auth headers, custom toolbars).
  const AppBackButton({this.onPressed, super.key}) : _forAppBar = false;

  /// AppBar-ready leading slot with edge inset and alignment.
  const AppBackButton.leading({this.onPressed, super.key}) : _forAppBar = true;

  final VoidCallback? onPressed;
  final bool _forAppBar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final foreground = scheme.onSurface;
    final canPop = onPressed != null || Navigator.of(context).canPop();

    if (!canPop) return const SizedBox.shrink();

    final size = spacing.xlg + 2; // 34
    final radius = BorderRadius.circular(context.appRadius.field); // 8

    final button = Tooltip(
      message: MaterialLocalizations.of(context).backButtonTooltip,
      child: AppPressable(
        child: Material(
          color: scheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.95),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed ?? () => Navigator.of(context).maybePop(),
            splashColor: foreground.withValues(alpha: 0.08),
            highlightColor: foreground.withValues(alpha: 0.04),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                Icons.chevron_left_rounded,
                size: spacing.md + 2, // 18
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    );

    if (!_forAppBar) return button;

    return Padding(
      padding: EdgeInsets.only(left: spacing.xs),
      child: Align(alignment: Alignment.centerLeft, child: button),
    );
  }
}
