// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/app/shell/help/widgets/help_step_tile.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The setup walkthrough: what to do first, and in what order.
///
/// The order is the one a real library follows — rules before records,
/// records before loans — because a loan taken before the loan rules exist
/// has no due date to compute from.
class HelpGuidePanel extends StatelessWidget {
  const HelpGuidePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;

    final steps = <(String, String)>[
      (l10n.helpGuideStep1Title, l10n.helpGuideStep1Body),
      (l10n.helpGuideStep2Title, l10n.helpGuideStep2Body),
      (l10n.helpGuideStep3Title, l10n.helpGuideStep3Body),
      (l10n.helpGuideStep4Title, l10n.helpGuideStep4Body),
      (l10n.helpGuideStep5Title, l10n.helpGuideStep5Body),
      (l10n.helpGuideStep6Title, l10n.helpGuideStep6Body),
      (l10n.helpGuideStep7Title, l10n.helpGuideStep7Body),
      (l10n.helpGuideStep8Title, l10n.helpGuideStep8Body),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.helpGuideIntro,
          style: context.appTextStyles.body.copyWith(color: colors.textMuted),
        ),
        SizedBox(height: spacing.md),
        AppSectionHeader(title: l10n.helpGuideStepsTitle, dense: true),
        SizedBox(height: spacing.sm),
        for (final (index, step) in steps.indexed)
          HelpStepTile(
            number: index + 1,
            title: step.$1,
            body: step.$2,
          ),
      ],
    );
  }
}
