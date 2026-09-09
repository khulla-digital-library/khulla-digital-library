// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/app/shell/help/widgets/help_note_tile.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Day-to-day working notes: the keys that move focus, what a scanner does,
/// and what "local-first" costs and buys.
///
/// The keyboard table lists only what the framework already honours —
/// traversal, activation and dismissal. Nothing here is an app-defined
/// accelerator, because the app defines none yet, and a printed shortcut that
/// does nothing is worse than no list at all.
class HelpTipsPanel extends StatelessWidget {
  const HelpTipsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    final keys = <(String, String)>[
      (l10n.helpTipsKeyNextField, l10n.helpTipsKeyTab),
      (l10n.helpTipsKeyPrevField, l10n.helpTipsKeyShiftTab),
      (l10n.helpTipsKeyActivate, l10n.helpTipsKeyEnter),
      (l10n.helpTipsKeyDismiss, l10n.helpTipsKeyEscape),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppSectionHeader(title: l10n.helpTipsKeyboardTitle, dense: true),
        SizedBox(height: spacing.sm),
        for (final (action, keystroke) in keys)
          _KeyRow(action: action, keystroke: keystroke),
        SizedBox(height: spacing.md),
        HelpNoteTile(
          icon: AppIcons.scan,
          title: l10n.helpTipsScannerTitle,
          body: l10n.helpTipsScannerBody,
        ),
        HelpNoteTile(
          icon: AppIcons.search,
          title: l10n.helpTipsListsTitle,
          body: l10n.helpTipsListsBody,
        ),
        HelpNoteTile(
          icon: AppIcons.cloudOff,
          title: l10n.helpTipsOfflineTitle,
          body: l10n.helpTipsOfflineBody,
        ),
        HelpNoteTile(
          icon: AppIcons.privacy,
          title: l10n.helpTipsDataTitle,
          body: l10n.helpTipsDataBody,
        ),
      ],
    );
  }
}

/// One row of the keyboard table: what it does, and the keys that do it.
class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.action, required this.keystroke});

  final String action;
  final String keystroke;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              action,
              style: typography.body.copyWith(color: colors.textMuted),
            ),
          ),
          SizedBox(width: spacing.sm),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.muted,
              border: Border.all(color: colors.hairline),
              borderRadius: BorderRadius.circular(context.appRadius.control),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.xs,
                vertical: spacing.xxs,
              ),
              child: Text(
                keystroke,
                style: typography.micro.copyWith(color: colors.textHigh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
