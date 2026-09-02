import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_icon_button}
/// A square icon-only control with the 44px target the rest of the app uses.
///
/// [tooltip] is required, not optional: an icon-only control with no label is
/// unreachable by a screen reader and unguessable by everyone else, and on a
/// desktop tool that is most of the toolbar.
/// {@endtemplate}
class AppIconButton extends StatelessWidget {
  /// {@macro app_icon_button}
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.tone,
    this.filled = false,
    this.selected = false,
    super.key,
  });

  /// The glyph. Use the `_rounded` set.
  final IconData icon;

  /// What the control does, already localized. Doubles as the semantics
  /// label.
  final String tooltip;

  /// Called on press. Null disables the control, keeping the tooltip.
  final VoidCallback? onPressed;

  /// Overrides the glyph colour — [AppStatusTone.danger] for a destructive
  /// row action, for instance. Defaults to [ColorScheme.onSurfaceVariant].
  final AppStatusTone? tone;

  /// Gives the button a tinted fill, for a primary toolbar action.
  final bool filled;

  /// Marks the control as the active choice — a toggled view switch.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final resolvedTone = tone;
    final foreground = selected
        ? scheme.primary
        : resolvedTone?.foreground(context) ?? scheme.onSurfaceVariant;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: spacing.md + 4),
        color: foreground,
        visualDensity: VisualDensity.standard,
        constraints: BoxConstraints.tightFor(
          width: spacing.xlg + spacing.sm,
          height: spacing.xlg + spacing.sm,
        ),
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(
            filled || selected
                ? (resolvedTone ?? AppStatusTone.brand).background(context)
                : Colors.transparent,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.appRadius.control),
            ),
          ),
          overlayColor: WidgetStatePropertyAll(
            foreground.withValues(alpha: 0.08),
          ),
          mouseCursor: const WidgetStateProperty<MouseCursor?>.fromMap(
            <WidgetStatesConstraint, MouseCursor?>{
              WidgetState.disabled: SystemMouseCursors.basic,
              WidgetState.any: SystemMouseCursors.click,
            },
          ),
        ),
      ),
    );
  }
}
