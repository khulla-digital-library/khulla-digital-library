import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';

/// [OutlinedButton] with app-wide press scale and overlay feedback.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    required this.onPressed,
    required this.child,
    this.style,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).outlinedButtonTheme.style;

    return AppPressable(
      enabled: onPressed != null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: AppButtonInteraction.outlined(style ?? themeStyle),
        child: child,
      ),
    );
  }
}
