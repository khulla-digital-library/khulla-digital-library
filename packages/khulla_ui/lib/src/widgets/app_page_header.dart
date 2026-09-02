import 'package:khulla_ui/khulla_ui.dart';

/// Back control and page title on one row for nested screens.
///
/// Use in scrollable page bodies; pair with [AppBackButton.leading] when the
/// header lives in an [AppBar] instead.
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    required this.title,
    this.trailing,
    this.onBackPressed,
    super.key,
  });

  final String title;
  final Widget? trailing;
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Row(
      children: [
        AppBackButton(onPressed: onBackPressed),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.25,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
