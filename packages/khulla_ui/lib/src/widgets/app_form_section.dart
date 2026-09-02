import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_form_section}
/// A titled group of related fields, with the vertical rhythm the form recipe
/// calls for: [AppSpacing.sm] between fields, [AppSpacing.lg] before the next
/// section.
///
/// Grouping is what makes a long editor readable — *Identification*,
/// *Availability*, *Fines* — so prefer three short sections to one column of
/// twelve fields.
/// {@endtemplate}
class AppFormSection extends StatelessWidget {
  /// {@macro app_form_section}
  const AppFormSection({
    required this.children,
    this.title,
    this.description,
    this.trailing,
    super.key,
  });

  /// The fields, in tab order.
  final List<Widget> children;

  /// Section heading. Omit for a lead section that needs no title.
  final String? title;

  /// Supporting line under [title].
  final String? description;

  /// One action for the section — *Add another copy*.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final heading = title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (heading != null) ...[
          AppSectionHeader(
            title: heading,
            subtitle: description,
            trailing: trailing,
            dense: true,
          ),
          SizedBox(height: spacing.md),
        ],
        for (final (index, field) in children.indexed) ...[
          if (index > 0) SizedBox(height: spacing.sm),
          field,
        ],
      ],
    );
  }
}
