import 'package:khulla/gen/assets.gen.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Which Khulla logo asset to draw.
enum AppLogoVariant {
  /// Horizontal wordmark — `primary_logo.png`.
  primary,

  /// Icon-only K mark — `submark_logo.png`.
  submark,
}

/// A Khulla logo loaded through generated [Assets] constants.
///
/// [AppLogoVariant.primary] is the horizontal wordmark; give it a [height] and
/// let the width follow the asset aspect ratio. [AppLogoVariant.submark] is
/// square — pass [height] or [width], or neither for [AppMetrics.iconLarge].
///
/// Platform favicons and launcher icons use `favicon_logo.png` via
/// `icons_launcher.yaml`, not this widget.
class AppLogo extends StatelessWidget {
  const AppLogo({
    this.variant = AppLogoVariant.submark,
    this.height,
    this.width,
    super.key,
  });

  /// Horizontal wordmark at [height], width unconstrained.
  const AppLogo.primary({this.height, this.width, super.key})
    : variant = AppLogoVariant.primary;

  /// Square icon mark; [size] sets both [height] and [width].
  const AppLogo.submark({double? size, super.key})
    : variant = AppLogoVariant.submark,
      height = size,
      width = size;

  final AppLogoVariant variant;
  final double? height;
  final double? width;

  AssetGenImage get _asset => switch (variant) {
    AppLogoVariant.primary => Assets.images.logos.primaryLogo,
    AppLogoVariant.submark => Assets.images.logos.submarkLogo,
  };

  @override
  Widget build(BuildContext context) {
    final metrics = context.appMetrics;
    final side = height ?? width ?? metrics.iconLarge;

    return _asset.image(
      height: variant == AppLogoVariant.primary ? (height ?? side) : side,
      width: variant == AppLogoVariant.submark ? side : width,
      fit: BoxFit.contain,
      semanticLabel: context.l10n.appName,
    );
  }
}
