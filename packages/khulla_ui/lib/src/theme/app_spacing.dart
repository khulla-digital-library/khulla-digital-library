import 'dart:ui';

import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_spacing}
/// Spacing scale tokens for consistent layout throughout the app.
/// {@endtemplate}
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// {@macro app_spacing}
  const AppSpacing({
    this.xxs = 4,
    this.xs = 8,
    this.sm = 12,
    this.md = 16,
    this.lg = 24,
    this.xlg = 32,
    this.xxlg = 48,
    this.page = 24,
    this.pageVertical = 20,
    this.dialog = 32,
    this.menuIconGap = 10,
    this.navIconGap = 16,
    this.emptyStateVertical = 96,
  });

  /// Extra extra small spacing: 4px.
  final double xxs;

  /// Extra small spacing: 8px.
  final double xs;

  /// Small spacing: 12px.
  final double sm;

  /// Medium spacing: 16px.
  final double md;

  /// Horizontal screen-edge inset for page content: 24px.
  final double page;

  /// Vertical inset on the page's scroll container: 20px. Slightly tighter
  /// than the horizontal inset, which is what keeps a dense screen from
  /// wasting a row of height at the top.
  final double pageVertical;

  /// Inner padding of a dialog's scroll region: 32px. A dialog is read
  /// closer than a page and earns the extra room.
  final double dialog;

  /// Icon-to-label gap inside a menu item: 10px.
  final double menuIconGap;

  /// Icon-to-label gap inside a navigation row: 16px. Wider than a menu's,
  /// because a rail is scanned by icon first and read second.
  final double navIconGap;

  /// Vertical padding around a full-page empty state: 96px.
  final double emptyStateVertical;

  /// Large spacing: 24px.
  final double lg;

  /// Extra large spacing: 32px.
  final double xlg;

  /// Extra extra large spacing: 48px.
  final double xxlg;

  @override
  AppSpacing copyWith({
    double? xxs,
    double? xs,
    double? sm,
    double? md,
    double? page,
    double? pageVertical,
    double? dialog,
    double? menuIconGap,
    double? navIconGap,
    double? emptyStateVertical,
    double? lg,
    double? xlg,
    double? xxlg,
  }) {
    return AppSpacing(
      xxs: xxs ?? this.xxs,
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      page: page ?? this.page,
      pageVertical: pageVertical ?? this.pageVertical,
      dialog: dialog ?? this.dialog,
      menuIconGap: menuIconGap ?? this.menuIconGap,
      navIconGap: navIconGap ?? this.navIconGap,
      emptyStateVertical: emptyStateVertical ?? this.emptyStateVertical,
      lg: lg ?? this.lg,
      xlg: xlg ?? this.xlg,
      xxlg: xxlg ?? this.xxlg,
    );
  }

  @override
  AppSpacing lerp(AppSpacing? other, double t) {
    if (other is! AppSpacing) return this;
    return AppSpacing(
      xxs: lerpDouble(xxs, other.xxs, t)!,
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      page: lerpDouble(page, other.page, t)!,
      pageVertical: lerpDouble(pageVertical, other.pageVertical, t)!,
      dialog: lerpDouble(dialog, other.dialog, t)!,
      menuIconGap: lerpDouble(menuIconGap, other.menuIconGap, t)!,
      navIconGap: lerpDouble(navIconGap, other.navIconGap, t)!,
      emptyStateVertical: lerpDouble(
        emptyStateVertical,
        other.emptyStateVertical,
        t,
      )!,
      lg: lerpDouble(lg, other.lg, t)!,
      xlg: lerpDouble(xlg, other.xlg, t)!,
      xxlg: lerpDouble(xxlg, other.xxlg, t)!,
    );
  }
}
