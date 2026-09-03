import 'package:khulla_ui/khulla_ui.dart';

/// The title row every page opens with: an optional back control, the title,
/// and a slot for the page's actions.
///
/// The title is the largest type on a page and the only place the page-header
/// rung is used. A page must not draw its own heading with a bare [Text] —
/// that is how eight screens end up with eight title sizes.
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

    return Row(
      children: [
        AppBackButton(onPressed: onBackPressed),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.appTextStyles.pageHeader.copyWith(
              color: context.appColors.ink100,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
