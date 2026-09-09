// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/app/shell/help/widgets/help_about_panel.dart';
import 'package:khulla/app/shell/help/widgets/help_guide_panel.dart';
import 'package:khulla/app/shell/help/widgets/help_tips_panel.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Which panel of [HelpDialog] is showing.
enum HelpTab {
  /// How to set the library up and run the desk.
  guide,

  /// Keyboard, scanners, and what the local-first model means day to day.
  tips,

  /// What this product is, who made it, and where the source lives.
  about,
}

/// The manual, reachable from the account menu on any screen.
///
/// It is a dialog rather than a route because help is read *over* the work in
/// progress — an operator halfway through a check-out should not lose the
/// screen to find out what a hold queue is.
///
/// The three panels are deliberately separate: one is read once during setup,
/// one is skimmed at the desk, and one is looked up when reporting a bug.
class HelpDialog extends StatefulWidget {
  const HelpDialog({super.key});

  /// Presents the help dialog.
  static Future<void> show(BuildContext context) => AppDialog.show<void>(
    context: context,
    title: context.l10n.helpDialogTitle,
    width: AppDialogWidth.xxxxl,
    content: const HelpDialog(),
    // No footer button: help is read and dismissed, never confirmed, and a
    // lone *Close* under eight steps of prose only adds a second thing that
    // does what the close chip already does.
    actionsBuilder: (_) => const SizedBox.shrink(),
  );

  @override
  State<HelpDialog> createState() => _HelpDialogState();
}

class _HelpDialogState extends State<HelpDialog> {
  HelpTab _tab = HelpTab.guide;

  String _label(HelpTab tab) {
    final l10n = context.l10n;
    return switch (tab) {
      HelpTab.guide => l10n.helpTabGuide,
      HelpTab.tips => l10n.helpTabTips,
      HelpTab.about => l10n.helpTabAbout,
    };
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Hugging its labels rather than stretching: the track is a control,
        // and a control stretched to a 768px dialog reads as a header band
        // with three words lost in it.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: AppSegmentedControl<HelpTab>(
            value: _tab,
            items: HelpTab.values,
            itemLabel: _label,
            onChanged: (tab) => setState(() => _tab = tab),
          ),
        ),
        SizedBox(height: spacing.md),
        switch (_tab) {
          HelpTab.guide => const HelpGuidePanel(),
          HelpTab.tips => const HelpTipsPanel(),
          HelpTab.about => const HelpAboutPanel(),
        },
      ],
    );
  }
}
