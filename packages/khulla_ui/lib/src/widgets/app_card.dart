import 'package:khulla_ui/khulla_ui.dart';

/// The standard raised surface: white on the canvas, hairline, soft shadow.
///
/// Everything on a page that is not the page itself is one of these. The
/// depth is deliberately shallow — a hairline plus a whisper of shadow —
/// because a screen holding twelve cards with real drop shadows reads as a
/// mockup rather than a tool. Hovering a tappable card lifts it one step, so
/// "this responds to a click" is shown rather than only implied.
class AppCard extends StatefulWidget {
  const AppCard({
    required this.child,
    this.padding,
    this.onTap,
    this.selected = false,
    this.bordered = true,
    this.elevated = true,
    this.tone,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  /// The card's content.
  final Widget child;

  /// Inner padding. Defaults to `spacing.md` on every side.
  final EdgeInsetsGeometry? padding;

  /// Makes the whole card pressable, with hover and focus feedback.
  final VoidCallback? onTap;

  /// Draws the selected outline — a picked row, an active filter panel.
  final bool selected;

  /// Whether to draw the hairline. Turn it off for a card nested inside
  /// another surface that already has one.
  final bool bordered;

  /// Whether to cast the ambient card shadow.
  final bool elevated;

  /// Tints the card's fill and hairline with a status wash — a warning
  /// banner, a danger panel. Null keeps the neutral surface.
  final AppStatusTone? tone;

  /// How the card clips its child. Antialiased by default so a full-bleed
  /// image or a table inside it follows the corner radius.
  final Clip clipBehavior;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final shadows = context.appShadows;
    final tone = widget.tone;
    final interactive = widget.onTap != null;
    final lifted = interactive && _hovered;

    final fill = switch (tone) {
      null => scheme.surface,
      final value => value.background(context),
    };
    final borderColor = switch (tone) {
      _ when widget.selected => scheme.primary,
      null => colors.hairlineStrong,
      final value => value.border(context),
    };

    final body = Padding(
      padding: widget.padding ?? EdgeInsets.all(spacing.md),
      child: widget.child,
    );

    return MouseRegion(
      cursor: interactive ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: interactive ? (_) => setState(() => _hovered = true) : null,
      onExit: interactive ? (_) => setState(() => _hovered = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(context.appRadius.card),
          border: widget.bordered
              ? Border.all(
                  color: lifted && !widget.selected
                      ? colors.hairlineStrong
                      : borderColor,
                  width: widget.selected ? 1.5 : 1,
                )
              : null,
          boxShadow: widget.elevated
              ? (lifted ? shadows.raised : shadows.card)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(context.appRadius.card),
          clipBehavior: widget.clipBehavior,
          child: interactive
              ? InkWell(
                  onTap: widget.onTap,
                  hoverColor: Colors.transparent,
                  focusColor: scheme.primary.withValues(alpha: 0.06),
                  child: body,
                )
              : body,
        ),
      ),
    );
  }
}
