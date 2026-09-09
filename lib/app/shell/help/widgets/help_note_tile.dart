// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:khulla/app/shell/help/widgets/help_step_tile.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A titled paragraph with a glyph beside it — one point worth knowing.
///
/// Used for the tips panel, where each entry stands on its own rather than
/// following from the one above it, which is what separates it from
/// [HelpStepTile] and its running order.
class HelpNoteTile extends StatelessWidget {
  const HelpNoteTile({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  /// The glyph, carrying the subject at a glance.
  final AppIconSpec icon;

  /// The point's heading.
  final String title;

  /// The explanation under it.
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
          Padding(
            padding: EdgeInsets.only(top: spacing.xxs),
            child: AppIcon(icon, size: 18, color: colors.mutedForeground),
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
