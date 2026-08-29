import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_content_constraint}
/// Centres [child] and caps its width at
/// [AppBreakpoints.contentMaxWidth].
///
/// The correct minimum for a screen that has no dedicated tablet layout.
/// {@endtemplate}
class AppContentConstraint extends StatelessWidget {
  /// {@macro app_content_constraint}
  const AppContentConstraint({required this.child, super.key});

  /// Content to constrain.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.appBreakpoints.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}
