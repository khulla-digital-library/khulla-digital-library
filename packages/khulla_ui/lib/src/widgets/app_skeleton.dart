import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_skeleton}
/// A pulsing placeholder block for content that is on its way.
///
/// Use it where the shape of what is loading is already known — a table of
/// rows, a detail pane of fields — so the layout does not jump when the read
/// returns. Where the shape is unknown, [AppLoadingIndicator] is honest and
/// this is not.
///
/// It pulses opacity rather than sweeping a gradient: one animation for the
/// whole screen, no shader, and nothing that reads as motion on a page a
/// librarian keeps open all day.
/// {@endtemplate}
class AppSkeleton extends StatefulWidget {
  /// {@macro app_skeleton}
  const AppSkeleton({
    this.width,
    this.height = 16,
    this.radius,
    this.shape = BoxShape.rectangle,
    super.key,
  });

  /// Block width. Null fills the slot.
  final double? width;

  /// Block height.
  final double height;

  /// Corner radius. Defaults to [AppRadius.badge]; ignored for a circle.
  final double? radius;

  /// Rectangle for text and rows, circle for an avatar slot.
  final BoxShape shape;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final isCircle = widget.shape == BoxShape.circle;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.85).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            shape: widget.shape,
            borderRadius: isCircle
                ? null
                : BorderRadius.circular(
                    widget.radius ?? context.appRadius.badge,
                  ),
          ),
        ),
      ),
    );
  }
}
