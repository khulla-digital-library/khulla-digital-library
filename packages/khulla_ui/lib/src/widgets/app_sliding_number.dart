import 'package:khulla_ui/khulla_ui.dart';

/// An integer that slides out and a new one that slides in.
///
/// Height is locked to the line box and clipped, so a parent row does not
/// jump while the glyphs travel. Duration is [AppMotion.long].
class AppSlidingNumber extends StatefulWidget {
  /// Creates a sliding integer.
  const AppSlidingNumber({
    required this.value,
    required this.style,
    super.key,
  });

  /// The current figure.
  final int value;

  /// Type for both glyphs. Use [AppTextStyles.numeric] so tabular figures
  /// keep the width stable.
  final TextStyle style;

  @override
  State<AppSlidingNumber> createState() => _AppSlidingNumberState();
}

class _AppSlidingNumberState extends State<AppSlidingNumber>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _t;
  int _from = 0;
  int _to = 0;

  @override
  void initState() {
    super.initState();
    _from = _to = widget.value;
    _controller = AnimationController(vsync: this, value: 1);
    _t = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.appMotion.long;
  }

  @override
  void didUpdateWidget(covariant AppSlidingNumber oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _from = oldWidget.value;
      _to = widget.value;
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
    final fontSize = widget.style.fontSize ?? 14;
    final lineHeight = fontSize * 1.35;
    final up = _to > _from;

    return SizedBox(
      height: lineHeight,
      child: ClipRect(
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: fontSize * 1.75),
          child: AnimatedBuilder(
            animation: _t,
            builder: (context, _) {
              final t = _t.value;
              if (_from == _to) {
                return Center(child: Text('$_to', style: widget.style));
              }

              final travel = lineHeight * t;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.translate(
                    offset: Offset(0, (up ? -1 : 1) * travel),
                    child: Opacity(
                      opacity: (1 - t).clamp(0, 1),
                      child: Text('$_from', style: widget.style),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, (up ? 1 : -1) * lineHeight * (1 - t)),
                    child: Transform.scale(
                      scale: 0.9 + 0.1 * Curves.easeOutBack.transform(t),
                      child: Text('$_to', style: widget.style),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
