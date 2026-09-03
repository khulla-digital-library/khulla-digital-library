import 'package:khulla_ui/khulla_ui.dart';

/// A dashed rounded-rectangle outline.
///
/// Flutter has no dashed border, and every screen that needs one grows its
/// own painter with a slightly different dash rhythm. This is the single
/// implementation: **6px on, 6px off, 2px stroke**, following the container
/// radius, which is the rhythm the design system uses for filter chips and
/// file drop zones.
///
/// The dash pattern deliberately does not scale with the shape, so a wide
/// drop zone and a small chip read as the same material.
class AppDashedBorder extends StatelessWidget {
  const AppDashedBorder({
    required this.child,
    this.color,
    this.radius,
    super.key,
  });

  /// What the outline surrounds.
  final Widget child;

  /// The stroke color. Defaults to the hairline.
  final Color? color;

  /// The corner radius. Defaults to the container rung.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final borders = context.appBorders;
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color ?? context.appColors.hairline,
        radius: radius ?? context.appRadius.container,
        strokeWidth: borders.dashedStroke,
        on: borders.dashOn,
        off: borders.dashOff,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.on,
    required this.off,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double on;
  final double off;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            strokeWidth / 2,
            strokeWidth / 2,
            size.width - strokeWidth,
            size.height - strokeWidth,
          ),
          Radius.circular(radius),
        ),
      );

    for (final metric in outline.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + on).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + off;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.on != on ||
      oldDelegate.off != off;
}
