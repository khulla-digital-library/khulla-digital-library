import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_palette.dart';

/// Elevation, as the three shadows this product actually uses.
///
/// Material's `elevation` numbers are not reachable from a token, and an
/// `elevation: 2` on one widget rarely matches an `elevation: 2` on another
/// once surface tint is involved. These are plain [BoxShadow] lists instead,
/// so a card, a menu and a sheet can be given the same depth by name.
///
/// The scale is deliberately shallow. Depth in this UI comes from the
/// hairline; the shadow only stops a white card from cutting out of the
/// canvas. A heavy drop shadow is what makes a dashboard look like a mockup
/// rather than a tool.
class AppShadows extends ThemeExtension<AppShadows> {
  const AppShadows({
    required this.card,
    required this.raised,
    required this.overlay,
  });

  /// The light scale.
  factory AppShadows.light() => AppShadows(
    card: [
      BoxShadow(
        color: AppPalette.shadowLight.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
    raised: [
      BoxShadow(
        color: AppPalette.shadowLight.withValues(alpha: 0.06),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
      BoxShadow(
        color: AppPalette.shadowLight.withValues(alpha: 0.04),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
    overlay: [
      BoxShadow(
        color: AppPalette.shadowLight.withValues(alpha: 0.12),
        blurRadius: 28,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: AppPalette.shadowLight.withValues(alpha: 0.06),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// The dark scale. A shadow is nearly invisible on a dark canvas, so the
  /// same three roles are carried by a heavier, tighter black.
  factory AppShadows.dark() => AppShadows(
    card: [
      BoxShadow(
        color: AppPalette.shadowDark.withValues(alpha: 0.28),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ],
    raised: [
      BoxShadow(
        color: AppPalette.shadowDark.withValues(alpha: 0.36),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
    overlay: [
      BoxShadow(
        color: AppPalette.shadowDark.withValues(alpha: 0.55),
        blurRadius: 30,
        offset: const Offset(0, 14),
      ),
    ],
  );

  /// A card, a table, a stat tile — anything resting on the canvas.
  final List<BoxShadow> card;

  /// A hovered card, a pinned table header that has content scrolled under it.
  final List<BoxShadow> raised;

  /// A menu, a dialog, a side sheet — anything floating above the page.
  final List<BoxShadow> overlay;

  @override
  AppShadows copyWith({
    List<BoxShadow>? card,
    List<BoxShadow>? raised,
    List<BoxShadow>? overlay,
  }) {
    return AppShadows(
      card: card ?? this.card,
      raised: raised ?? this.raised,
      overlay: overlay ?? this.overlay,
    );
  }

  @override
  AppShadows lerp(AppShadows? other, double t) {
    if (other is! AppShadows) return this;
    return AppShadows(
      card: BoxShadow.lerpList(card, other.card, t)!,
      raised: BoxShadow.lerpList(raised, other.raised, t)!,
      overlay: BoxShadow.lerpList(overlay, other.overlay, t)!,
    );
  }
}
