import 'package:flutter/material.dart';
import 'package:khulla_ui/khulla_ui.dart' show AppSpacing;
import 'package:khulla_ui/src/extensions/build_context_extensions.dart';
import 'package:khulla_ui/src/theme/app_spacing.dart' show AppSpacing;
import 'package:khulla_ui/src/widgets/app_content_constraint.dart';

/// Bottom action strip with safe-area inset and horizontal page padding.
class AppBottomBar extends StatelessWidget {
  /// {@macro app_bottom_bar}
  const AppBottomBar({
    required this.child,
    super.key,
    this.constrained = true,
    this.padding,
  });

  /// Primary action or button row.
  final Widget child;

  /// When true, wraps [child] in [AppContentConstraint].
  final bool constrained;

  /// Overrides the default page padding. When null, uses [AppSpacing.page]
  /// horizontally and [AppSpacing.xs] / [AppSpacing.sm] vertically.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    var content = child;
    if (constrained) {
      content = AppContentConstraint(child: content);
    }
    return SafeArea(
      top: false,
      child: Padding(
        padding:
            padding ??
            EdgeInsets.fromLTRB(
              spacing.page,
              spacing.xs,
              spacing.page,
              spacing.sm,
            ),
        child: content,
      ),
    );
  }
}
