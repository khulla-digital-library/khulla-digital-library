import 'package:khulla_ui/khulla_ui.dart';

/// App-wide circular loading indicator.
///
/// Use instead of a raw [CircularProgressIndicator] so stroke weight and
/// sizing stay consistent across screens, sheets, and buttons.
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    this.color,
    this.strokeWidth = 2,
    this.size,
    super.key,
  });

  /// Spinner color. Defaults to the theme's [ColorScheme.primary].
  final Color? color;

  /// Ring thickness. Defaults to `2` for the app's lighter loader look.
  final double strokeWidth;

  /// When set, constrains the spinner to a square of this side length.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color ?? scheme.primary,
    );

    final side = size;
    if (side == null) return indicator;

    return SizedBox(width: side, height: side, child: indicator);
  }
}
