import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:khulla_ui/khulla_ui.dart';
import 'package:khulla_ui/src/theme/app_button_interaction.dart'
    show AppButtonInteraction;

/// Adds a subtle scale dip so taps feel responsive. Material buttons inside
/// still render their own ink ripple via [AppButtonInteraction].
class AppPressable extends StatefulWidget {
  const AppPressable({
    required this.child,
    this.enabled = true,
    this.scale = 0.985,
    this.haptic = true,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double scale;

  /// Light impact on press — skipped when false, disabled, or on a
  /// platform with no haptics engine (desktop and web).
  final bool haptic;

  /// Whether the current platform can actually produce haptic feedback.
  ///
  /// Asking for it anywhere else costs a platform-channel round trip on every
  /// press and returns nothing.
  static bool get _supportsHaptics =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable>
    with SingleTickerProviderStateMixin {
  static const _pressDuration = Duration(milliseconds: 160);
  static const _releaseDuration = Duration(milliseconds: 240);
  static const Cubic _curve = Curves.easeInOutCubic;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _pressDuration,
    reverseDuration: _releaseDuration,
  );

  late Animation<double> _scaleAnimation = _buildScaleAnimation();

  Animation<double> _buildScaleAnimation() => Tween<double>(
    begin: 1,
    end: widget.scale,
  ).animate(CurvedAnimation(parent: _controller, curve: _curve));

  @override
  void didUpdateWidget(covariant AppPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scale != widget.scale) {
      _scaleAnimation = _buildScaleAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (value) {
      if (widget.haptic && AppPressable._supportsHaptics) {
        unawaited(HapticFeedback.lightImpact());
      }
      _controller.forward();
      return;
    }
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}
