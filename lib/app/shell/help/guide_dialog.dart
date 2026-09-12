// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/app/shell/help/widgets/help_guide_panel.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The setup manual, reachable from the account menu on any screen.
///
/// It is a dialog rather than a route because help is read *over* the work in
/// progress — an operator halfway through a check-out should not lose the
/// screen to find out what a hold queue is.
class HelpGuideDialog extends StatelessWidget {
  const HelpGuideDialog({super.key});

  /// Presents the guide dialog.
  static Future<void> show(BuildContext context) => AppDialog.show<void>(
    context: context,
    title: context.l10n.guideDialogTitle,
    width: AppDialogWidth.xxxxl,
    content: const HelpGuideDialog(),
    // No footer button: the guide is read and dismissed, never confirmed,
    // and a lone *Close* under eight steps of prose only adds a second thing
    // that does what the close chip already does.
    actionsBuilder: (_) => const SizedBox.shrink(),
  );

  @override
  Widget build(BuildContext context) => const HelpGuidePanel();
}
