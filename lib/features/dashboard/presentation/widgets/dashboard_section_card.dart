import 'package:khulla_ui/khulla_ui.dart';

/// A titled card holding one of the dashboard's board sections.
///
/// It gives every section the same header, the same minimum height, and the
/// same padding, so the board stays a grid rather than a stack of cards that
/// each found their own size. [minBodyHeight] is a *minimum*, not a fixed
/// height: the card grows with text scaling instead of clipping it.
class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.trailing,
    this.minBodyHeight = 200,
    super.key,
  });

  /// Section heading.
  final String title;

  /// The section's body — today, an empty state.
  final Widget child;

  /// Supporting line under [title].
  final String? subtitle;

  /// Glyph beside the heading.
  final IconData? icon;

  /// The section's single action.
  final Widget? trailing;

  /// Floor for the body's height, so two cards side by side start level.
  final double minBodyHeight;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSectionHeader(
            title: title,
            subtitle: subtitle,
            icon: icon,
            trailing: trailing,
            dense: true,
          ),
          SizedBox(height: spacing.md),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: minBodyHeight),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
