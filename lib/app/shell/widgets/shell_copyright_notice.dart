// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The one-line product copyright, shared by the rail footer and More sheet.
///
/// Both spots are shell chrome, so the copy and styling live here once:
/// caption text fed by `shellCopyright` in the ARB. The year renders from the
/// clock so the line never needs a yearly edit; the name comes from `appName`
/// so a rebrand touches one string.
///
/// [textAlign] defaults to centre for the phone sheet; the rail passes
/// [TextAlign.start] so the line reads with the account row above it.
/// [showDivider] draws the hairline the sheet needs because phones never see
/// the rail footer.
class ShellCopyrightNotice extends StatelessWidget {
  const ShellCopyrightNotice({
    this.textAlign = TextAlign.center,
    this.showDivider = false,
    super.key,
  });

  final TextAlign textAlign;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;
    final spacing = context.appSpacing;

    final notice = Text(
      l10n.shellCopyright(
        '${DateTime.now().year}',
        l10n.appName,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: context.appTextStyles.caption.copyWith(
        color: colors.mutedForeground,
      ),
    );

    if (!showDivider) return notice;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: colors.hairline),
        SizedBox(height: spacing.sm),
        notice,
      ],
    );
  }
}
