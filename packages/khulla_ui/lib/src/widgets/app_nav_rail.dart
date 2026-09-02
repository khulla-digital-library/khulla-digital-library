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
/// Selection is painted as a filled brand row, not a tinted pill: on a screen
/// this dense the active section has to be findable from the corner of an eye.
class AppNavRail extends StatefulWidget {
  const AppNavRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.extended = false,
    this.leading,
    this.trailing,
    this.footer,
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

  /// The rail's width when it is showing labels.
  static const double extendedWidth = 248;

  /// The rail's width when it is glyphs only.
  static const double collapsedWidth = 76;

  @override
  State<AppNavRail> createState() => _AppNavRailState();
}

class _AppNavRailState extends State<AppNavRail> {
  final Set<int> _expanded = <int>{};

  @override
  void initState() {
    super.initState();
    _expandSelected();
  }

  @override
  void didUpdateWidget(covariant AppNavRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) _expandSelected();
  }

  void _expandSelected() {
    final index = widget.selectedIndex;
    if (index >= 0 &&
        index < widget.destinations.length &&
        widget.destinations[index].children.isNotEmpty) {
      _expanded.add(index);
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

    return Container(
      width: extended ? AppNavRail.extendedWidth : AppNavRail.collapsedWidth,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(right: BorderSide(color: colors.hairline)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (head != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  extended ? spacing.md : spacing.sm,
                  spacing.md,
                  extended ? spacing.md : spacing.sm,
                  spacing.md,
                ),
                child: head,
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: extended ? spacing.sm : spacing.sm + 2,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (index, destination)
                        in widget.destinations.indexed)
                      _RailItem(
                        destination: destination,
                        extended: extended,
                        selected: index == widget.selectedIndex,
                        expanded: _expanded.contains(index),
                        onTap: () {
                          widget.onDestinationSelected(index);
                          if (extended && destination.children.isNotEmpty) {
                            _toggle(index);
                          }
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
                  extended ? spacing.sm : spacing.sm + 2,
                  spacing.xs,
                  extended ? spacing.sm : spacing.sm + 2,
                  spacing.xs,
                ),
                child: tail,
              ),
            if (bottom != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  extended ? spacing.sm : spacing.xs,
                  spacing.xs,
                  extended ? spacing.sm : spacing.xs,
                  spacing.sm,
                ),
                child: bottom,
              ),
          ],
        ),
      ),
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
    final scheme = context.colorScheme;
    final colors = context.appColors;
    final radius = BorderRadius.circular(context.appRadius.tile);

    final foreground = selected ? scheme.onPrimary : colors.textMuted;
    final glyph = IconTheme.merge(
      data: IconThemeData(color: foreground, size: 20),
      child: selected ? destination.selectedIcon : destination.icon,
    );

    final row = Material(
      color: selected ? scheme.primary : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        hoverColor: selected
            ? Colors.transparent
            : colors.neutralSoft.withValues(alpha: 0.9),
        child: SizedBox(
          height: extended ? 42 : 44,
          child: extended
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                  child: Row(
                    children: [
                      glyph,
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: selected
                                ? scheme.onPrimary
                                : colors.textHigh,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (destination.badge case final count?) ...[
                        SizedBox(width: spacing.xs),
                        _RailBadge(label: count, selected: selected),
                      ],
                      if (onToggle != null) ...[
                        SizedBox(width: spacing.xxs),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: foreground,
                        ),
                      ],
                    ],
                  ),
                )
              : Center(child: glyph),
        ),
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
      padding: EdgeInsets.only(bottom: spacing.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          item,
          if (showChildren)
            Padding(
              padding: EdgeInsets.only(
                left: spacing.md + spacing.xs,
                top: spacing.xxs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final child in children) _RailChildRow(child: child),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RailChildRow extends StatelessWidget {
  const _RailChildRow({required this.child});

  final AppNavChild child;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final radius = BorderRadius.circular(context.appRadius.control);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: child.selected ? colors.brandSoft : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: child.onSelected,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 5,
                  margin: EdgeInsets.only(right: spacing.xs + 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: child.selected
                        ? scheme.primary
                        : colors.hairlineStrong,
                  ),
                ),
                Expanded(
                  child: Text(
                    child.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: child.selected ? scheme.primary : colors.textMuted,
                      fontWeight: child.selected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (child.badge case final count?)
                  Text(
                    count,
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.textMuted,
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

class _RailBadge extends StatelessWidget {
  const _RailBadge({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: selected
            ? scheme.onPrimary.withValues(alpha: 0.22)
            : colors.neutralSoft,
        borderRadius: BorderRadius.circular(context.appRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: selected ? scheme.onPrimary : colors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
