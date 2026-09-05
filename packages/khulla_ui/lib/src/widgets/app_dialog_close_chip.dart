import 'package:khulla_ui/khulla_ui.dart';

/// The close chip: a bordered square that sits *outside* a dialog's corner,
/// slides a little further out on hover and turns its glyph a quarter turn.
class AppDialogCloseChip extends StatefulWidget {
  const AppDialogCloseChip({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<AppDialogCloseChip> createState() => _AppDialogCloseChipState();
}

class _AppDialogCloseChipState extends State<AppDialogCloseChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final motion = context.appMotion;
    final metrics = context.appMetrics;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedSlide(
          duration: motion.layout,
          curve: motion.standard,
          offset: _hovered ? const Offset(0.15, -0.15) : Offset.zero,
          child: Material(
            color: scheme.surface,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.appRadius.item),
            ),
            child: AnimatedContainer(
              duration: motion.layout,
              curve: motion.standard,
              padding: EdgeInsets.all(spacing.xs),
              decoration: BoxDecoration(
                color: _hovered ? colors.secondary : scheme.surface,
                borderRadius: BorderRadius.circular(context.appRadius.item),
                border: Border.all(color: colors.hairline),
                boxShadow: context.appShadows.raised,
              ),
              child: AnimatedRotation(
                duration: motion.layout,
                curve: motion.standard,
                turns: _hovered ? 0.25 : 0,
                child: AppIcon(
                  AppIcons.close,
                  size: metrics.iconLarge,
                  color: colors.ink500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
