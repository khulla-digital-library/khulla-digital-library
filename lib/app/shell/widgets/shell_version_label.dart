// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/core/config/app_info.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The app name and version, shared by the rail footer and More sheet.
///
/// Both spots are shell chrome, so the label lives here once: the product
/// name from `appName`, with `v` plus [AppInfo.version] underneath — which
/// `tools/version.dart` generates from `version:` in `pubspec.yaml`. The
/// version part is deliberately not localized: it reads the same in every
/// language, same as the About panel.
///
/// [textAlign] defaults to centre for the phone sheet; the rail passes
/// [TextAlign.start] so the line reads with the account row above it.
/// [showDivider] draws the hairline the sheet needs because phones never see
/// the rail footer.
class ShellVersionLabel extends StatelessWidget {
  const ShellVersionLabel({
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

    final label = Text(
      '${l10n.appName} · v${AppInfo.version}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: context.appTextStyles.caption.copyWith(
        color: colors.mutedForeground,
      ),
    );

    if (!showDivider) return label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, thickness: 1, color: colors.hairline),
        SizedBox(height: spacing.sm),
        label,
      ],
    );
  }
}
