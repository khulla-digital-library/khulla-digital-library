// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla_ui/khulla_ui.dart';

/// One tappable row inside an [AppDropdownMenu]: an optional leading glyph,
/// the label, and a check when selected.
class AppDropdownMenuItem extends StatelessWidget {
  const AppDropdownMenuItem({
    required this.label,
    required this.selected,
    required this.itemRadius,
    this.icon,
    this.enabled = true,
    this.onTap,
    super.key,
  });

  final String label;
  final AppIconSpec? icon;
  final bool selected;
  final bool enabled;
  final double itemRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final metrics = context.appMetrics;
    final foreground = context.colorScheme.onSurface;
    final glyph = icon;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(itemRadius),
        splashFactory: NoSplash.splashFactory,
        hoverColor: enabled ? colors.tints.menuItemFocus : Colors.transparent,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.xs,
            vertical: spacing.xs + 2,
          ),
          child: Row(
            children: [
              if (glyph != null) ...[
                AppIcon(glyph, size: metrics.icon, color: colors.ink500),
                SizedBox(width: spacing.menuIconGap),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.appTextStyles.label.copyWith(
                    color: foreground,
                  ),
                ),
              ),
              if (selected) ...[
                SizedBox(width: spacing.xs),
                AppIcon(
                  AppIcons.check,
                  size: metrics.icon,
                  color: colors.brand,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// What an [AppDropdownMenu] shows when search filters every item out.
class AppDropdownEmptyState extends StatelessWidget {
  const AppDropdownEmptyState({
    required this.itemExtent,
    this.message,
    super.key,
  });

  final String? message;
  final double itemExtent;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;

    return SizedBox(
      height: itemExtent * 2,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing.sm),
          child: Text(
            message ?? '',
            textAlign: TextAlign.center,
            style: context.appTextStyles.caption.copyWith(
              color: colors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
