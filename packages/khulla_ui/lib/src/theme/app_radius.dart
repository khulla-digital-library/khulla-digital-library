import 'dart:ui';

import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_radius}
/// Corner-radius scale for consistent rounding throughout the app, named by
/// the component role each radius is meant for rather than by size.
///
/// Kept separate from [AppSpacing] so radius can be tuned without affecting
/// layout spacing, even though some values happen to match.
/// {@endtemplate}
class AppRadius extends ThemeExtension<AppRadius> {
  /// {@macro app_radius}
  const AppRadius({
    this.badge = 4,
    this.field = 10,
    this.control = 10,
    this.tile = 12,
    this.card = 12,
    this.banner = 20,
    this.bar = 28,
    this.pill = 999,
  });

  /// Smallest accents nested inside a surface: dots, tiny icon corners.
  final double badge;

  /// Text fields, search fields, small pickers.
  final double field;

  /// Circular icon buttons / small control chips.
  final double control;

  /// Small tiles, tags, icon containers, secondary surfaces.
  final double tile;

  /// Cards, dialogs, bottom sheets, list tiles — the default surface radius.
  final double card;

  /// Large hero surfaces / feature banners.
  final double banner;

  /// Fully-rounded search/filter bars and image rails.
  final double bar;

  /// True full-round badges/status chips. [BorderRadius] clamps this to the
  /// shortest side automatically, so it always renders as a stadium shape.
  final double pill;

  @override
  AppRadius copyWith({
    double? badge,
    double? field,
    double? control,
    double? tile,
    double? card,
    double? banner,
    double? bar,
    double? pill,
  }) {
    return AppRadius(
      badge: badge ?? this.badge,
      field: field ?? this.field,
      control: control ?? this.control,
      tile: tile ?? this.tile,
      card: card ?? this.card,
      banner: banner ?? this.banner,
      bar: bar ?? this.bar,
      pill: pill ?? this.pill,
    );
  }

  @override
  AppRadius lerp(AppRadius? other, double t) {
    if (other is! AppRadius) return this;
    return AppRadius(
      badge: lerpDouble(badge, other.badge, t)!,
      field: lerpDouble(field, other.field, t)!,
      control: lerpDouble(control, other.control, t)!,
      tile: lerpDouble(tile, other.tile, t)!,
      card: lerpDouble(card, other.card, t)!,
      banner: lerpDouble(banner, other.banner, t)!,
      bar: lerpDouble(bar, other.bar, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
    );
  }
}
