import 'package:khulla_ui/khulla_ui.dart';

/// The system's only spinner: a three-quarter arc, spinning at a constant
/// rate.
///
/// Two sizes carry two different meanings and should not be swapped. Inside a
/// button it replaces the label, so it is small enough not to change the
/// control's height. In a section or a page it sits alone in the empty space
/// where the content will land, so it is large enough to be the only thing
/// on screen worth looking at.
class AppSpinner extends StatelessWidget {
  const AppSpinner({this.color, this.size, this.strokeWidth = 2, super.key});

  /// The arc's color. Defaults to the brand.
  final Color? color;

  /// The square the arc is drawn in. Defaults to the section size.
  final double? size;

  /// The arc's thickness.
  final double strokeWidth;

  /// The size used inside a button, where the control must not resize.
  static const double buttonSize = 19;

  /// The size used for a section or page load.
  static const double sectionSize = 32;

  @override
  Widget build(BuildContext context) {
    final side = size ?? sectionSize;
    return SizedBox(
      width: side,
      height: side,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
        color: color ?? context.colorScheme.primary,
      ),
    );
  }
}
