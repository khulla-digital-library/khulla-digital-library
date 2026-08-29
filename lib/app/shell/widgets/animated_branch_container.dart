import 'package:flutter/material.dart';

/// Custom container for the branch [Navigator]s of a `StatefulShellRoute`.
///
/// Renders every branch in a `Stack` so their state stays alive, while the
/// active branch slides in from the direction of travel and the outgoing
/// branch slides away, giving a smooth page transition when switching tabs.
class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    this.duration = const Duration(milliseconds: 220),
    super.key,
  });

  /// The index (in [children]) of the active branch to display.
  final int currentIndex;

  /// The branch navigator widgets managed by this container.
  final List<Widget> children;

  /// How long the branch transition takes.
  final Duration duration;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late int _activeIndex = widget.currentIndex;
  late int _previousIndex = widget.currentIndex;
  late int _direction = 1;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    value: 1,
  );

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        _previousIndex = _activeIndex;
        _activeIndex = widget.currentIndex;
        _direction = _activeIndex > _previousIndex ? 1 : -1;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < widget.children.length; i++) _buildBranch(i),
        ],
      ),
    );
  }

  Widget _buildBranch(int index) {
    final isActive = index == _activeIndex;
    final isPrevious = index == _previousIndex;
    final isAnimating =
        _controller.isAnimating && _activeIndex != _previousIndex;

    var opacity = isActive ? 1.0 : 0.0;
    var fractionalOffset = Offset.zero;

    if (isAnimating && isActive) {
      fractionalOffset = Offset((1 - _controller.value) * 0.12 * _direction, 0);
    } else if (isAnimating && isPrevious) {
      opacity = 1 - _controller.value;
      fractionalOffset = Offset(-_controller.value * 0.12 * _direction, 0);
    }

    return Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: !isActive,
        child: Transform.translate(
          offset: Offset(
            fractionalOffset.dx * MediaQuery.sizeOf(context).width,
            0,
          ),
          child: TickerMode(
            enabled: isActive,
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}
