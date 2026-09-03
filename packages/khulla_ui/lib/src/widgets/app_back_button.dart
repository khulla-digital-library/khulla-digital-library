import 'package:khulla_ui/khulla_ui.dart';

/// The back control used by nested pages and custom toolbars.
///
/// A bordered square with a brand chevron rather than Material's bare arrow:
/// it sits on the page-header line beside a title, where an unboxed glyph
/// would float without an anchor.
///
/// Use [AppBackButton] in a page body and [AppBackButton.leading] in
/// [AppBar.leading], which needs the extra edge inset and alignment.
class AppBackButton extends StatelessWidget {
  /// A standalone back control.
  const AppBackButton({this.onPressed, super.key}) : _forAppBar = false;

  /// An [AppBar]-ready back control.
  const AppBackButton.leading({this.onPressed, super.key}) : _forAppBar = true;

  /// Called on press. Defaults to popping the nearest route.
  final VoidCallback? onPressed;

  final bool _forAppBar;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final canPop = onPressed != null || Navigator.of(context).canPop();

    if (!canPop) return const SizedBox.shrink();

    final radius = BorderRadius.circular(context.appRadius.container);

    final button = Tooltip(
      message: MaterialLocalizations.of(context).backButtonTooltip,
      child: AppRipple(
        onTap: onPressed ?? () => Navigator.of(context).maybePop(),
        borderRadius: radius,
        child: Container(
          width: metrics.iconButtonMedium,
          height: metrics.iconButtonMedium,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: radius,
            border: Border.all(color: colors.hairline),
          ),
          child: AppIcon(
            AppIcons.chevronLeft,
            size: metrics.icon,
            color: context.colorScheme.primary,
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
