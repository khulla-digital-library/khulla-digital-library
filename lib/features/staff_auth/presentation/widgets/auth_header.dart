import 'package:khulla_ui/khulla_ui.dart';

/// The heading above an auth form: what this screen is, and what it will do.
class AuthHeader extends StatelessWidget {
  const AuthHeader({required this.title, required this.description, super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: typography.pageHeader.copyWith(color: colors.ink100),
        ),
        SizedBox(height: spacing.xs),
        Text(
          description,
          style: typography.body.copyWith(color: colors.textMuted),
        ),
      ],
    );
  }
}
