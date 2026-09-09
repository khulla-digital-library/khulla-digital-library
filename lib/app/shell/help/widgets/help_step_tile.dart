// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla_ui/khulla_ui.dart';

/// One numbered step of the getting-started walkthrough.
///
/// The number is drawn from the step's position rather than written into the
/// copy, so reordering the walkthrough — or translating it — never leaves a
/// "3." sitting above what is now the second step.
class HelpStepTile extends StatelessWidget {
  const HelpStepTile({
    required this.number,
    required this.title,
    required this.body,
    super.key,
  });

  /// Where this step falls in the walkthrough, counting from one.
  final int number;

  /// The step's heading.
  final String title;

  /// What the operator actually does.
  final String body;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.brandSoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: typography.micro.copyWith(
                color: colors.brandStrong,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.sectionTitle.copyWith(
                    color: colors.textHigh,
                  ),
                ),
                SizedBox(height: spacing.xxs),
                Text(
                  body,
                  style: typography.body.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
