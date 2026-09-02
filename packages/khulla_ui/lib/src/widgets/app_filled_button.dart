import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';

/// [FilledButton] with app-wide press scale and overlay feedback.
class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
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
    final themeStyle = Theme.of(context).filledButtonTheme.style;

    return AppPressable(
      enabled: onPressed != null,
      child: FilledButton(
        onPressed: onPressed,
        style: AppButtonInteraction.filled(style ?? themeStyle),
        child: child,
      ),
    );
  }
}
