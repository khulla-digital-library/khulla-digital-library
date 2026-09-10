// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/app/shell/help/help_dialog.dart';
import 'package:khulla/app/shell/widgets/shell_destinations.dart';
import 'package:khulla/app/shell/widgets/shell_version_label.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Opens the sheet listing every section, for a window too narrow to show
/// them all in the bottom bar.
///
/// A bottom bar holds four destinations before the labels start eating each
/// other; this app has eight. Rather than dropping the four that did not fit,
/// the bar keeps the daily ones and this sheet carries the whole list —
/// including the sub-sections, which the bar could never have shown at all.
Future<void> showShellMoreSheet(
  BuildContext context, {
  required List<ShellDestination> destinations,
  required String current,
}) => AppBottomSheet.show<void>(
  context: context,
  title: context.l10n.shellMoreTitle,
  heightFactor: AppBottomSheet.defaultHeightFactor,
  builder: (sheetContext) => _MoreList(
    destinations: destinations,
    current: current,
  ),
);

class _MoreList extends StatelessWidget {
  const _MoreList({required this.destinations, required this.current});

  final List<ShellDestination> destinations;
  final String current;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final destination in destinations) ...[
          _MoreRow(
            label: destination.label,
            icon: destination.icon,
            selected: isSelectedShellRoute(
              current,
              destination.route,
              [
                for (final d in destinations) ...[
                  d.route,
                  for (final child in d.children) child.route,
                ],
              ],
            ),
            onTap: () => context.go(destination.route),
          ),
          for (final child in destination.children)
            Padding(
              padding: EdgeInsets.only(left: spacing.xlg),
              child: _MoreRow(
                label: child.label,
                icon: AppIcons.subEntry,
                selected: isSelectedShellRoute(
                  current,
                  child.route,
                  [for (final c in destination.children) c.route],
                ),
                onTap: () => context.go(child.route),
              ),
            ),
          SizedBox(height: spacing.xxs),
        ],
        // Phones never see the rail footer, and the account menu that carries
        // help on a window lives in it — so the manual hangs here instead,
        // below the sections and above the version line.
        _MoreRow(
          label: context.l10n.shellHelp,
          icon: AppIcons.help,
          selected: false,
          onTap: () => unawaited(HelpDialog.show(context)),
        ),
        SizedBox(height: spacing.xxs),
        const ShellVersionLabel(showDivider: true),
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppIconSpec icon;
  final bool selected;

  /// Run after the sheet closes — the sheet is always dismissed first, so a
  /// row never leaves the panel sitting over what it just opened.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final radius = BorderRadius.circular(context.appRadius.control);

    return Material(
      color: selected ? colors.brandSoft : Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
        borderRadius: radius,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              AppIcon(
                icon,
                size: spacing.md + 2,
                color: selected ? scheme.primary : colors.textMuted,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: selected ? scheme.primary : colors.textHigh,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
