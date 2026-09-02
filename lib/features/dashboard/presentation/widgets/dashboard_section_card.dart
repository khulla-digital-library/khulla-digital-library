import 'package:khulla_ui/khulla_ui.dart';

/// A titled card holding one of the dashboard's board sections.
///
/// Every section gets the same header, the same padding and the same optional
/// trailing control, so the board stays a grid rather than a stack of cards
/// that each found their own shape. [minBodyHeight] is a floor, not a fixed
/// height: the card grows with text scaling instead of clipping it.
class DashboardSectionCard extends StatelessWidget {
  const DashboardSectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.trailing,
    this.minBodyHeight = 0,
    this.bodyPadding,
    super.key,
  });

  /// Section heading.
  final String title;

  /// The section's body.
  final Widget child;

  /// Supporting line under [title].
  final String? subtitle;

  /// Glyph beside the heading.
  final IconData? icon;

  /// The section's single control — a period picker, a *view all* link.
  final Widget? trailing;

  /// Floor for the body's height, so two cards side by side start level.
  final double minBodyHeight;

  /// Padding around the body. Zero-horizontal for a card holding a table,
  /// which draws its own row insets.
  final EdgeInsetsGeometry? bodyPadding;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final body = Padding(
      padding: bodyPadding ?? EdgeInsets.zero,
      child: child,
    );

    return AppCard(
      padding: EdgeInsets.all(spacing.md),
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
          if (minBodyHeight > 0)
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minBodyHeight),
              child: body,
            )
          else
            body,
        ],
      ),
    );
  }
}
