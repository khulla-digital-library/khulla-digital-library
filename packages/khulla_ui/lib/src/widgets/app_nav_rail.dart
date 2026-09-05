import 'package:khulla_ui/khulla_ui.dart';

/// The side navigation for every window wider than a phone.
///
/// Hand-built rather than wrapped around Material's [NavigationRail], because
/// the product needs three things that widget does not offer: a destination
/// that expands into its sub-sections, a count pinned to a row, and a single
/// visual language across the collapsed and extended states. Both states are
/// the same widget with the same items in the same order, so dragging a window
/// across 1200px reveals labels rather than rebuilding the navigation.
///
/// Selection is a **warm tint plus a 4px half-height bar on the left edge**,
/// not a filled row. The tint is the same one hover uses, so moving down the
/// rail does not flash a different color at every step; the bar is what
/// actually says *you are here*, and it is deliberately short and rounded on
/// its outer edge rather than a full-height stripe.
class AppNavRail extends StatefulWidget {
  const AppNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.leading,
    this.trailing,
    this.footer,
    this.wrapSafeArea = true,
    super.key,
  }) : assert(destinations.length >= 2, 'Need at least 2 destinations');

  /// Index of the active destination.
  final int selectedIndex;

  /// Called with the index of the destination the user picked.
  final ValueChanged<int> onDestinationSelected;

  /// Destinations, in display order. Shared with [AppNavBar].
  final List<AppNavDestination> destinations;

  /// Whether to show labels beside the glyphs.
  final bool extended;

  /// Pinned above the destinations — the product mark.
  final Widget? leading;

  /// Pinned under the destinations, above [footer] — the theme toggle, a
  /// sign-out row.
  final Widget? trailing;

  /// The bottom-most slot, drawn full-bleed inside the rail's padding — a
  /// promo card, a storage meter.
  final Widget? footer;

  /// Whether to wrap the rail in [SafeArea]. The shell turns this off when it
  /// already wrapped the chrome row once.
  final bool wrapSafeArea;

  /// The rail's width when it is showing labels.
  static const double extendedWidth = 240;

  /// The rail's width when it is glyphs only.
  static const double collapsedWidth = 64;

  @override
  State<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends State<AppNavRail> {
  final Set<int> _expanded = <int>{};

  @override
  void initState() {
    super.initState();
    for (final (index, destination) in widget.destinations.indexed) {
      if (destination.children.isNotEmpty) _expanded.add(index);
    }
  }

  void _toggle(int index) => setState(() {
    if (!_expanded.remove(index)) _expanded.add(index);
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final extended = widget.extended;
    final head = widget.leading;
    final tail = widget.trailing;
    final bottom = widget.footer;
    final applySafeArea = widget.wrapSafeArea;

    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Optional slot above the destinations — product mark, search, or
        // a workspace switcher. The shell draws its brand header above the
        // rail instead, so this stays null in production.
        if (head != null)
          SizedBox(
            height: context.appMetrics.topBarHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.sm),
              child: Center(child: head),
            ),
          ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              spacing.sm,
              spacing.xs,
              spacing.sm,
              spacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final (index, destination) in widget.destinations.indexed)
                  _RailItem(
                    destination: destination,
                    extended: extended,
                    selected:
                        index == widget.selectedIndex &&
                        !destination.children.any((child) => child.selected),
                    expanded: _expanded.contains(index),
                    onTap: () {
                      if (extended && destination.children.isNotEmpty) {
                        _toggle(index);
                        return;
                      }
                      widget.onDestinationSelected(index);
                    },
                    onToggle: destination.children.isEmpty || !extended
                        ? null
                        : () => _toggle(index),
                  ),
              ],
            ),
          ),
        ),
        if (tail != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.sm,
              spacing.xs,
              spacing.sm,
              spacing.xs,
            ),
            child: tail,
          ),
        if (bottom != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.sm,
              spacing.xs,
              spacing.sm,
              spacing.sm,
            ),
            child: bottom,
          ),
      ],
    );

    return Container(
      width: extended ? AppNavRail.extendedWidth : AppNavRail.collapsedWidth,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: colors.hairline)),
      ),
      child: applySafeArea ? SafeArea(right: false, child: rail) : rail,
    );
  }
}

/// One destination row, plus its children when the rail is extended.
class _RailItem extends StatelessWidget {
  const _RailItem({
    required this.destination,
    required this.extended,
    required this.selected,
    required this.expanded,
    required this.onTap,
    required this.onToggle,
  });

  final AppNavDestination destination;
  final bool extended;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final radius = BorderRadius.circular(context.appRadius.control);

    final foreground = selected ? colors.brand : colors.ink400;
    final glyph = IconTheme.merge(
      data: IconThemeData(color: foreground, size: metrics.iconNav),
      child: destination.icon,
    );

    final row = _RailRowSurface(
      selected: selected,
      radius: radius,
      onTap: onTap,
      child: SizedBox(
        height: metrics.navRowHeight,
        child: extended
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                child: Row(
                  children: [
                    SizedBox(
                      width: metrics.iconNav,
                      child: Center(child: glyph),
                    ),
                    SizedBox(width: spacing.navIconGap),
                    Expanded(
                      child: Text(
                        destination.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.appTextStyles.bodyLarge.copyWith(
                          color: foreground,
                        ),
                      ),
                    ),
                    if (destination.badge case final count?) ...[
                      SizedBox(width: spacing.xs),
                      _RailBadge(label: count, selected: selected),
                    ],
                    if (onToggle != null) ...[
                      SizedBox(width: spacing.xxs),
                      AnimatedRotation(
                        duration: context.appMotion.overlay,
                        turns: expanded ? 0 : -0.25,
                        child: AppIcon(
                          AppIcons.chevronDown,
                          size: metrics.icon,
                          color: foreground,
                        ),
                      ),
                    ],
                  ],
                ),
              )
            : Center(child: glyph),
      ),
    );

    final item = extended
        ? row
        : Tooltip(
            message: destination.label,
            preferBelow: false,
            child: row,
          );

    final children = destination.children;
    final showChildren = extended && expanded && children.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          item,
          if (showChildren)
            Padding(
              padding: EdgeInsets.only(top: spacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, child) in children.indexed)
                    _RailChildRow(
                      child: child,
                      isLast: index == children.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The tinted row plus the active bar, shared by every rail item.
///
/// The bar is drawn *outside* the row's padding and clipped to nothing when
/// the row is not selected, so selection never shifts the label.
class _RailRowSurface extends StatefulWidget {
  const _RailRowSurface({
    required this.selected,
    required this.radius,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final BorderRadius radius;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_RailRowSurface> createState() => _RailRowSurfaceState();
}

class _RailRowSurfaceState extends State<_RailRowSurface> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final motion = context.appMotion;
    final tinted = widget.selected || _hovered;

    return AppRipple(
      onTap: widget.onTap,
      borderRadius: widget.radius,
      pressScale: 1,
      onHoverChanged: (value) => setState(() => _hovered = value),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: motion.color,
            decoration: BoxDecoration(
              color: tinted ? colors.tints.navRow : Colors.transparent,
              borderRadius: widget.radius,
            ),
            child: widget.child,
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: AnimatedContainer(
                duration: motion.layout,
                curve: motion.standard,
                width: 4,
                height: widget.selected
                    ? context.appMetrics.navRowHeight / 2
                    : 0,
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(context.appRadius.pill),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RailChildRow extends StatelessWidget {
  const _RailChildRow({required this.child, required this.isLast});

  final AppNavChild child;

  /// Whether to draw the connector line below the bullet. The last child has
  /// nothing under it to connect to.
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final radius = BorderRadius.circular(context.appRadius.container);
    final metrics = context.appMetrics;
    final active = child.selected;
    final foreground = active ? colors.brand : colors.ink300;

    // Line the sub-item's label up with its parent's, so the rail reads as
    // one text column rather than two: the parent's inset, its glyph and the
    // icon gap, less what the bullet and its own gap already take.
    final indent =
        spacing.sm +
        metrics.iconNav +
        spacing.navIconGap -
        metrics.iconDense -
        spacing.xs;

    return AppRipple(
      onTap: child.onSelected,
      borderRadius: radius,
      pressScale: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? colors.tints.navRow : Colors.transparent,
          borderRadius: radius,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: indent, right: spacing.sm),
          child: IntrinsicHeight(
            child: Row(
              children: [
                _SubItemBullet(active: active, isLast: isLast),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: spacing.xs + 2),
                    child: Text(
                      child.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.appTextStyles.body.copyWith(
                        color: foreground,
                      ),
                    ),
                  ),
                ),
                if (child.badge case final count?)
                  Text(
                    count,
                    style: context.appTextStyles.micro.copyWith(
                      color: colors.ink500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The bullet before a sub-item, and the hairline that joins it to the next.
///
/// A filled dot ringed in the surface color rather than an outline circle:
/// at 6px an outlined dot is a smudge, and the ring is what lets the
/// connector line pass behind it cleanly.
class _SubItemBullet extends StatelessWidget {
  const _SubItemBullet({required this.active, required this.isLast});

  final bool active;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return SizedBox(
      width: context.appMetrics.iconDense,
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? colors.brand : colors.ink600,
            ),
          ),
          Expanded(
            child: isLast
                ? const SizedBox.shrink()
                : Container(width: 1, color: colors.hairlineStrong),
          ),
        ],
      ),
    );
  }
}

class _RailBadge extends StatelessWidget {
  const _RailBadge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? colors.brandSoft : colors.secondary,
        borderRadius: BorderRadius.circular(context.appRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: context.appTextStyles.micro.copyWith(
            color: selected ? colors.brand : colors.ink500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
