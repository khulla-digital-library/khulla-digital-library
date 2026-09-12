// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:go_router/go_router.dart';
import 'package:khulla/features/guide/domain/guide_block.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// An ordered walkthrough, drawn as a rail of numbered discs.
///
/// The connecting line between the discs is what makes it read as a sequence
/// rather than a list of unrelated tips — and the last step deliberately has
/// none, so the walkthrough visibly ends.
///
/// A step that names a screen offers it as a link. That is the difference
/// between a manual and a manual you can follow: the reader never has to
/// translate "Settings, then Loan rules" into a hunt through the rail.
class GuideStepList extends StatelessWidget {
  const GuideStepList(this.steps, {this.dense = false, super.key});

  /// The steps, in the order they are done.
  final GuideSteps steps;

  /// Tightens the rail for a summary on the guide's landing page, where the
  /// walkthrough is a preview rather than the thing being read.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final type = context.appTextStyles;
    final colors = context.appColors;
    final l10n = context.l10n;
    final entries = steps.steps;
    final discSize = dense ? 24.0 : 28.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in entries.indexed)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: discSize,
                      height: discSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.brandSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: type.micro.copyWith(
                          color: colors.brandStrong,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (index != entries.length - 1)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: EdgeInsets.symmetric(vertical: spacing.xxs),
                          color: colors.hairline,
                        ),
                      ),
                  ],
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: index == entries.length - 1 ? 0 : spacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: type.sectionTitle.copyWith(
                            color: colors.textHigh,
                          ),
                        ),
                        SizedBox(height: spacing.xxs),
                        Text(
                          step.body,
                          style: type.body.copyWith(color: colors.textMuted),
                        ),
                        if (step.route case final route?) ...[
                          SizedBox(height: spacing.xs),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: AppLinkButton(
                              onPressed: () => context.go(route),
                              color: context.colorScheme.primary,
                              child: Text(l10n.guideOpenScreen),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
