import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant {
  /// A filled button with the primary color.
  primary,

  /// A tonal filled button with a secondary color.
  secondary,

  /// An outlined button.
  outline,
}

/// Size variants for [AppButton].
enum AppButtonSize {
  /// A small button.
  small,

  /// A medium button.
  medium,

  /// A large button.
  large,
}

/// {@template app_button}
/// A styled button that composes Material's [FilledButton] and
/// [OutlinedButton] with app-specific sizing, variants, and a loading state.
/// {@endtemplate}
class AppButton extends StatelessWidget {
  /// {@macro app_button}
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    super.key,
  });

  /// Called when the button is tapped. Ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// The button's content, typically a [Text] widget.
  final Widget child;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// The size of the button.
  final AppButtonSize size;

  /// When true, disables the button and shows a progress indicator.
  final bool isLoading;

  /// Glyph before the label. A primary action that names a verb reads faster
  /// with one — *Add title*, *Check out* — but never use it for decoration.
  final IconData? icon;

  /// Glyph after the label, for a button that opens something: a chevron on
  /// a menu button, an arrow on "next".
  final IconData? trailingIcon;

  /// Stretches the button to its slot instead of hugging its label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final textTheme = context.textTheme;

    final padding = switch (size) {
      AppButtonSize.small => EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xxs,
      ),
      AppButtonSize.medium => EdgeInsets.symmetric(
        horizontal: spacing.sm + spacing.xxs,
        vertical: spacing.xs - 1,
      ),
      AppButtonSize.large => EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.xs + 2,
      ),
    };

    final minHeight = switch (size) {
      AppButtonSize.small => spacing.xlg,
      AppButtonSize.medium => spacing.xlg + spacing.xxs,
      AppButtonSize.large => spacing.xlg + spacing.sm,
    };

    final labelStyle = switch (size) {
      AppButtonSize.small => textTheme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      AppButtonSize.medium ||
      AppButtonSize.large => textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    };

    final glyphSize = size == AppButtonSize.small ? spacing.md : spacing.md + 2;

    final colorScheme = context.colorScheme;
    final indicatorColor = switch (variant) {
      AppButtonVariant.primary => colorScheme.onPrimary,
      AppButtonVariant.secondary => colorScheme.onSecondaryContainer,
      AppButtonVariant.outline => colorScheme.primary,
    };

    final style = ButtonStyle(
      padding: WidgetStatePropertyAll(padding),
      minimumSize: WidgetStatePropertyAll(Size(0, minHeight)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: WidgetStatePropertyAll(labelStyle),
    );
    final leading = icon;
    final trailing = trailingIcon;
    final label = leading == null && trailing == null
        ? child
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[
                Icon(leading, size: glyphSize),
                SizedBox(width: spacing.xs),
              ],
              Flexible(child: child),
              if (trailing != null) ...[
                SizedBox(width: spacing.xs),
                Icon(trailing, size: glyphSize),
              ],
            ],
          );

    final content = isLoading
        ? AppLoadingIndicator(color: indicatorColor, size: spacing.md + 2)
        : label;
    final onPressedOrNull = isLoading ? null : onPressed;

    final button = switch (variant) {
      AppButtonVariant.primary => AppFilledButton(
        onPressed: onPressedOrNull,
        style: AppButtonInteraction.filled(style),
        child: content,
      ),
      AppButtonVariant.secondary => AppPressable(
        enabled: onPressedOrNull != null,
        child: FilledButton.tonal(
          onPressed: onPressedOrNull,
          style: AppButtonInteraction.filled(style),
          child: content,
        ),
      ),
      AppButtonVariant.outline => AppOutlinedButton(
        onPressed: onPressedOrNull,
        style: AppButtonInteraction.outlined(style),
        child: content,
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
