import 'package:khulla_ui/khulla_ui.dart';

/// A low-emphasis inline action: *Clear filters*, *View all*, *Change
/// member*.
///
/// A named preset over [AppButton]'s ghost variant rather than a component of
/// its own, so that the dozen "quiet action beside a heading" call sites in
/// the app cannot drift apart from each other.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
    required this.onPressed,
    required this.child,
    this.icon,
    super.key,
  });

  /// Called on press. Null disables the action.
  final VoidCallback? onPressed;

  /// The label.
  final Widget child;

  /// An optional leading glyph.
  final IconData? icon;

  @override
  Widget build(BuildContext context) => AppButton(
    onPressed: onPressed,
    variant: AppButtonVariant.ghost,
    icon: icon,
    child: child,
  );
}
