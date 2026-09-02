import 'package:khulla_ui/khulla_ui.dart';

/// {@template app_form_row}
/// Places fields side by side where the slot is wide enough, and stacks them
/// where it is not.
///
/// Pair only fields that are genuinely independent — *Loan period* and *Fine
/// per day*, not *Address line 1* and *Address line 2*, where side-by-side
/// breaks the reading order a form depends on.
///
/// It measures its slot with [LayoutBuilder] rather than the window, so the
/// same row behaves correctly in a full-width page and in a side sheet.
/// {@endtemplate}
class AppFormRow extends StatelessWidget {
  /// {@macro app_form_row}
  const AppFormRow({
    required this.children,
    this.flexes,
    this.stackBelow = 520,
    super.key,
  });

  /// The fields to pair, in tab order.
  final List<Widget> children;

  /// Relative widths, one per child. Null gives every field equal width.
  final List<int>? flexes;

  /// Slot width below which the fields stack.
  final double stackBelow;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final weights = flexes;

    assert(
      weights == null || weights.length == children.length,
      'flexes must have one entry per child.',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < stackBelow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, field) in children.indexed) ...[
                if (index > 0) SizedBox(height: spacing.sm),
                field,
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, field) in children.indexed) ...[
              if (index > 0) SizedBox(width: spacing.sm),
              Expanded(flex: weights?[index] ?? 1, child: field),
            ],
          ],
        );
      },
    );
  }
}
