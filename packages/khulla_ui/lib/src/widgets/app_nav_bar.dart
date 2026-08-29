import 'package:khulla_ui/khulla_ui.dart';

/// Visual style for [AppNavBar].
enum AppNavBarVariant {
  /// Brand accent, top indicator, and animated icon swap on select.
  branded,

  /// Black-and-white only — outline icons, no indicator, no brand color.
  monochrome,
}

/// {@template app_nav_bar}
/// Minimal sticky bottom navigation bar.
/// {@endtemplate}
class AppNavBar extends StatelessWidget {
  /// {@macro app_nav_bar}
  const AppNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    this.backgroundColor,
    this.variant = AppNavBarVariant.branded,
    super.key,
  }) : assert(destinations.length >= 2, 'Need at least 2 destinations');

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;
  final Color? backgroundColor;
  final AppNavBarVariant variant;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final cs = context.colorScheme;
    final brightness = context.theme.brightness;

    final bgColor =
        backgroundColor ??
        (brightness == Brightness.light ? cs.surface : cs.surfaceContainerLow);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(top: spacing.xxs, bottom: spacing.xxs),
          child: Row(
            children: [
              for (int i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    isSelected: i == selectedIndex,
                    variant: variant,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.variant,
    required this.onTap,
  });

  final AppNavDestination destination;
  final bool isSelected;
  final AppNavBarVariant variant;
  final VoidCallback onTap;

  bool get _isMonochrome => variant == AppNavBarVariant.monochrome;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final textTheme = context.textTheme;
    final cs = context.colorScheme;

    final activeColor = _isMonochrome ? cs.onSurface : cs.primary;
    final inactiveColor = cs.onSurface.withValues(
      alpha: _isMonochrome ? 0.45 : 0.4,
    );

    const iconSize = 20.0;

    final icon = IconTheme(
      data: IconThemeData(
        color: isSelected ? activeColor : inactiveColor,
        size: iconSize,
      ),
      child: _isMonochrome || !isSelected
          ? destination.icon
          : destination.selectedIcon,
    );

    return InkWell(
      onTap: onTap,
      splashColor: activeColor.withValues(alpha: 0.12),
      highlightColor: activeColor.withValues(alpha: 0.06),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isMonochrome)
            SizedBox(height: spacing.xxs)
          else
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 2.5,
              width: isSelected ? 25 : 0,
              margin: EdgeInsets.only(bottom: spacing.xxs),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          if (_isMonochrome)
            icon
          else
            AnimatedScale(
              scale: isSelected ? 1.08 : 1,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.92,
                      end: 1,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey<bool>(isSelected),
                  child: icon,
                ),
              ),
            ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: (textTheme.labelSmall ?? const TextStyle()).copyWith(
              color: isSelected ? activeColor : inactiveColor,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              fontSize: 10,
            ),
            child: Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
