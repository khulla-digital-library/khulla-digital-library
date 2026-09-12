// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/app/shell/help/about_dialog.dart';
import 'package:khulla/app/shell/widgets/shell_destinations.dart';
import 'package:khulla/app/shell/widgets/shell_version_label.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/staff_auth/presentation/auth/cubit/auth_cubit.dart';
import 'package:khulla/features/users/presentation/user_labels.dart';
import 'package:khulla/features/users/presentation/widgets/staff_profile_dialog.dart';
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
  // The whole navigation tree, not a short picker: it earns more of the
  // screen than the default sheet does.
  heightFactor: 0.85,
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
    final l10n = context.l10n;
    final staff = context.watch<AuthCubit>().state.staff;

    // Eight sections, each with its sub-routes, plus the account row, help
    // and sign-out: the list is taller than the sheet on every phone, and a
    // `Column` in a fixed-height sheet can only overflow. The row count is
    // small and bounded, so a `SingleChildScrollView` is the right shape
    // here — see the lists-and-scrolling rule in CLAUDE.md.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The rail carries the account chip in its footer; a phone has no
          // rail, so who is signed in and how to sign out have to live here
          // instead — otherwise a compact window can never reach either.
          if (staff != null) ...[
            _MoreRow(
              label: staff.name,
              caption: staff.role.label(l10n),
              icon: AppIcons.person,
              selected: false,
              onTap: () => unawaited(StaffProfileDialog.show(context)),
            ),
            SizedBox(height: spacing.xxs),
            Divider(height: 1, color: context.appColors.hairline),
            SizedBox(height: spacing.xxs),
          ],
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
          // the guide and the about panel on a window lives in it — so both
          // hang here instead, below the sections and above the version line.
          _MoreRow(
            label: l10n.shellGuide,
            icon: AppIcons.openBook,
            selected: Routes.isUnder(current, Routes.guide),
            onTap: () => context.go(Routes.guide),
          ),
          SizedBox(height: spacing.xxs),
          _MoreRow(
            label: l10n.shellAbout,
            icon: AppIcons.info,
            selected: false,
            onTap: () => unawaited(HelpAboutDialog.show(context)),
          ),
          if (staff != null) ...[
            SizedBox(height: spacing.xxs),
            _MoreRow(
              label: l10n.shellSignOut,
              icon: AppIcons.signOut,
              selected: false,
              destructive: true,
              onTap: () => unawaited(context.read<AuthCubit>().signOut()),
            ),
          ],
          SizedBox(height: spacing.xxs),
          const ShellVersionLabel(),
        ],
      ),
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.caption,
    this.destructive = false,
  });

  final String label;

  /// A second line under [label] — the role under a name, say.
  final String? caption;
  final AppIconSpec icon;
  final bool selected;
  final bool destructive;

  /// Run after the sheet closes — the sheet is always dismissed first, so a
  /// row never leaves the panel sitting over what it just opened.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final scheme = context.colorScheme;
    final radius = BorderRadius.circular(context.appRadius.control);
    final captionText = caption;
    final foreground = destructive
        ? scheme.error
        : selected
        ? scheme.primary
        : colors.textHigh;

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
                color: destructive
                    ? scheme.error
                    : selected
                    ? scheme.primary
                    : colors.textMuted,
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: foreground,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                    if (captionText != null)
                      Text(
                        captionText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
