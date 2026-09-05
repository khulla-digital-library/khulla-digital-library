import 'package:khulla_ui/khulla_ui.dart';

/// What a button *means*, which decides all of its color.
///
/// The set is deliberately small and each entry has one job. If a screen
/// needs a look that is not here, the answer is almost always that it is
/// reaching for the wrong emphasis, not that the system is missing a variant.
enum AppButtonVariant {
  /// The one action a screen is built around. Filled brand.
  primary,

  /// A destructive confirmation. **Outlined, never filled** — a red slab
  /// reads as the recommended action, which is the opposite of the intent.
  destructive,

  /// The neutral action next to a primary one: Cancel, Back, a filter.
  outline,

  /// A quiet filled action on a grey surface — a toolbar's second control.
  secondary,

  /// Chrome-level actions with no surface of their own: a row's menu
  /// trigger, "Clear filters", a card's "View all".
  ghost,

  /// A confirming action that is not the page's primary — "Mark returned".
  success,

  /// A positive secondary action drawn as an outline — "Add a copy".
  successOutline,

  /// Inline navigation inside a sentence. Reads as a link, not a control.
  link,
}

/// How much room a button takes.
///
/// [small] is the default and is what most of the product uses: 40px, which
/// is what lets a filter row, a table toolbar and a dialog footer stay dense.
/// Reach for [large] only for a page's single most important action.
enum AppButtonSize {
  /// 40px. The default.
  small,

  /// 44px.
  medium,

  /// 48px.
  large,
}

/// {@template app_button}
/// The system's only button.
///
/// Every visual decision — height, radius, shadow, the ripple, the 0.95 press
/// dip, the disabled 50%, the loading spinner that replaces the label without
/// resizing the control — lives here, so a screen picks a [variant] and a
/// [size] and never writes a style. A one-off `ElevatedButton` with a custom
/// `ButtonStyle` is the thing this exists to prevent.
/// {@endtemplate}
class AppButton extends StatefulWidget {
  /// {@macro app_button}
  const AppButton({
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.small,
    this.isLoading = false,
    this.icon,
    this.trailingIcon,
    this.expand = false,
    super.key,
  });

  /// Called on press. Null disables the button; ignored while [isLoading].
  final VoidCallback? onPressed;

  /// The label, typically a [Text].
  final Widget child;

  /// What the button means.
  final AppButtonVariant variant;

  /// How much room it takes.
  final AppButtonSize size;

  /// Swaps the label for a spinner and swallows presses. The button keeps
  /// its width, so a row of controls does not reflow mid-submit.
  final bool isLoading;

  /// A glyph before the label. Worth it on a verb — *Add title*, *Check
  /// out* — and never worth it as decoration.
  final AppIconSpec? icon;

  /// A glyph after the label, for a button that opens something.
  final AppIconSpec? trailingIcon;

  /// Stretches to the slot instead of hugging the label.
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final spacing = context.appSpacing;
    final motion = context.appMotion;
    final scheme = context.colorScheme;
    final style = _styleFor(context, colors, scheme);

    final height = switch (widget.size) {
      AppButtonSize.small => metrics.buttonHeightSmall,
      AppButtonSize.medium => metrics.buttonHeightMedium,
      AppButtonSize.large => metrics.buttonHeightLarge,
    };

    final hasIcon = widget.icon != null || widget.trailingIcon != null;
    // Horizontal padding tightens when a glyph is present, so an icon+label
    // button reads at the same optical width as a label-only one.
    final basePadding = switch (widget.size) {
      AppButtonSize.small => spacing.sm,
      AppButtonSize.medium => spacing.md,
      AppButtonSize.large => spacing.xlg,
    };
    final padding = hasIcon ? basePadding - spacing.xxs : basePadding;

    final radius = BorderRadius.circular(
      widget.size == AppButtonSize.small
          ? context.appRadius.container
          : context.appRadius.control,
    );
    final gap = widget.size == AppButtonSize.small
        ? spacing.xs - 2
        : spacing.xs;

    final enabled = widget.onPressed != null && !widget.isLoading;
    final fill = _hovered && enabled ? style.hoverFill : style.fill;

    if (widget.variant == AppButtonVariant.link) {
      return _LinkButton(
        onPressed: enabled ? widget.onPressed : null,
        color: style.foreground,
        child: widget.child,
      );
    }

    final label = DefaultTextStyle.merge(
      style: context.appTextStyles.button.copyWith(color: style.foreground),
      child: IconTheme.merge(
        data: IconThemeData(
          color: style.foreground,
          size: metrics.iconInButton,
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              AppIcon(widget.icon!),
              SizedBox(width: gap),
            ],
            Flexible(child: widget.child),
            if (widget.trailingIcon != null) ...[
              SizedBox(width: gap),
              AppIcon(widget.trailingIcon!),
            ],
          ],
        ),
      ),
    );

    final surface = AnimatedContainer(
      duration: motion.color,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: padding),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: style.border),
        boxShadow: style.shadowed ? context.appShadows.card : null,
      ),
      child: Center(
        widthFactor: widget.expand ? null : 1,
        child: widget.isLoading
            ? AppSpinner(color: style.foreground, size: metrics.iconLarge)
            : label,
      ),
    );

    final button = Focus(
      onFocusChange: (value) => setState(() => _focused = value),
      child: AnimatedContainer(
        duration: motion.color,
        decoration: BoxDecoration(
          borderRadius: radius,
          // A 3px ring at half strength, drawn outside the control rather
          // than recoloring its border, so focus never shifts layout.
          boxShadow: _focused && enabled
              ? [
                  BoxShadow(
                    color: style.ring.withValues(alpha: 0.5),
                    spreadRadius: 3,
                  ),
                ]
              : null,
        ),
        child: AppRipple(
          onTap: enabled ? widget.onPressed : null,
          rippleColor: style.ripple,
          borderRadius: radius,
          onHoverChanged: (value) => setState(() => _hovered = value),
          child: surface,
        ),
      ),
    );

    return widget.expand
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }

  _ButtonStyle _styleFor(
    BuildContext context,
    AppColors colors,
    ColorScheme scheme,
  ) {
    final tints = colors.tints;
    return switch (widget.variant) {
      AppButtonVariant.primary => _ButtonStyle(
        fill: colors.brand,
        hoverFill: colors.brandStrong,
        foreground: scheme.onPrimary,
        border: colors.brandStrong.withValues(alpha: 0.7),
        ripple: colors.secondary,
        ring: colors.brand,
      ),
      AppButtonVariant.destructive => _ButtonStyle(
        fill: Colors.transparent,
        hoverFill: tints.destructiveHover,
        foreground: colors.danger,
        border: colors.danger,
        ripple: colors.danger.withValues(alpha: 0.2),
        ring: colors.danger,
      ),
      AppButtonVariant.outline => _ButtonStyle(
        fill: scheme.surface,
        hoverFill: colors.secondary,
        foreground: colors.ink500,
        border: colors.hairline,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
      ),
      AppButtonVariant.secondary => _ButtonStyle(
        fill: colors.secondary,
        hoverFill: colors.hairlineStrong.withValues(alpha: 0.5),
        foreground: colors.ink100,
        border: Colors.transparent,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
      ),
      // A transparent border, not the absence of one: a ghost button that
      // grows a border on hover would shift everything beside it.
      AppButtonVariant.ghost => _ButtonStyle(
        fill: Colors.transparent,
        hoverFill: colors.secondary,
        foreground: scheme.primary,
        border: Colors.transparent,
        ripple: colors.rippleNeutral,
        ring: colors.hairlineStrong,
        shadowed: false,
      ),
      AppButtonVariant.success => _ButtonStyle(
        fill: colors.success,
        hoverFill: colors.success.withValues(alpha: 0.9),
        foreground: colors.onSuccess,
        border: colors.success.withValues(alpha: 0.7),
        ripple: colors.secondary,
        ring: colors.success,
      ),
      AppButtonVariant.successOutline => _ButtonStyle(
        fill: Colors.transparent,
        hoverFill: tints.successHover,
        foreground: colors.success,
        border: colors.success,
        ripple: colors.success.withValues(alpha: 0.2),
        ring: colors.success,
      ),
      AppButtonVariant.link => _ButtonStyle(
        fill: Colors.transparent,
        hoverFill: Colors.transparent,
        foreground: colors.link,
        border: Colors.transparent,
        ripple: Colors.transparent,
        ring: Colors.transparent,
        shadowed: false,
      ),
    };
  }
}

/// The resolved colors of one variant.
class _ButtonStyle {
  const _ButtonStyle({
    required this.fill,
    required this.hoverFill,
    required this.foreground,
    required this.border,
    required this.ripple,
    required this.ring,
    this.shadowed = true,
  });

  final Color fill;
  final Color hoverFill;
  final Color foreground;
  final Color border;
  final Color ripple;
  final Color ring;
  final bool shadowed;
}

/// A link has no box: no height, no padding, no ripple — only the underline
/// on hover that every link on the web has.
class _LinkButton extends StatefulWidget {
  const _LinkButton({
    required this.onPressed,
    required this.color,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Color color;
  final Widget child;

  @override
  State<_LinkButton> createState() => _LinkButtonState();
}

class _LinkButtonState extends State<_LinkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: DefaultTextStyle.merge(
            style: context.appTextStyles.button.copyWith(
              color: widget.color,
              decoration: _hovered ? TextDecoration.underline : null,
              decorationColor: widget.color,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
