import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';

/// [TextButton] with app-wide press scale and overlay feedback.
class AppTextButton extends StatelessWidget {
  const AppTextButton({
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
    final themeStyle = Theme.of(context).textButtonTheme.style;

    return AppPressable(
      enabled: onPressed != null,
      child: TextButton(
        onPressed: onPressed,
        style: AppButtonInteraction.text(style ?? themeStyle),
        child: child,
      ),
    );
  }
}
