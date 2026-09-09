// Copyright (c) 2026 Khulla Digital Library contributors.
// SPDX-License-Identifier: MIT

import 'package:flutter/services.dart';
import 'package:khulla/core/config/app_info.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/widgets/app_logo.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What this product is, who built it, and where to find the source.
///
/// Every link copies to the clipboard instead of opening a browser: the app
/// carries no URL launcher, and on a locked-down library desktop a browser is
/// not guaranteed to be there to launch anyway. Copy always works.
class HelpAboutPanel extends StatelessWidget {
  const HelpAboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Column(
            children: [
              const AppLogo.submark(size: 64),
              SizedBox(height: spacing.sm),
              Text(
                l10n.appName,
                style: typography.title.copyWith(color: colors.textHigh),
              ),
              SizedBox(height: spacing.xxs),
              Text(
                l10n.helpAboutTagline,
                textAlign: TextAlign.center,
                style: typography.body.copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
        SizedBox(height: spacing.md),
        AppDetailRow(
          label: l10n.helpAboutVersionLabel,
          child: Text(
            AppInfo.version,
            style: typography.body.copyWith(color: colors.textHigh),
          ),
        ),
        AppDetailRow(
          label: l10n.helpAboutLicenseLabel,
          child: Text(
            AppInfo.license,
            style: typography.body.copyWith(color: colors.textHigh),
          ),
        ),
        SizedBox(height: spacing.md),
        AppSectionHeader(title: l10n.helpAboutAuthorTitle, dense: true),
        SizedBox(height: spacing.sm),
        Row(
          children: [
            AppAvatar(initials: AppInfo.authorInitials),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppInfo.authorName,
                    style: typography.sectionTitle.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                  Text(
                    l10n.helpAboutAuthorRole,
                    style: typography.caption.copyWith(
                      color: colors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: spacing.md),
        AppSectionHeader(title: l10n.helpAboutLinksTitle, dense: true),
        SizedBox(height: spacing.sm),
        _LinkRow(
          icon: AppIcons.discover,
          label: l10n.helpAboutLinkWebsite,
          url: AppInfo.authorSite,
        ),
        _LinkRow(
          icon: AppIcons.person,
          label: l10n.helpAboutLinkGithub,
          url: AppInfo.authorGithub,
        ),
        _LinkRow(
          icon: AppIcons.article,
          label: l10n.helpAboutLinkRepository,
          url: AppInfo.repositoryUrl,
        ),
        _LinkRow(
          icon: AppIcons.error,
          label: l10n.helpAboutLinkIssues,
          url: AppInfo.issuesUrl,
        ),
        SizedBox(height: spacing.sm),
        Text(
          l10n.helpAboutOpenSource,
          style: typography.caption.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}

/// One link: what it is, where it points, and a copy button on the end.
class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.url,
  });

  final AppIconSpec icon;
  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        children: [
          AppIcon(icon, size: 18, color: colors.mutedForeground),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: typography.label.copyWith(color: colors.textHigh),
                ),
                SelectableText(
                  url,
                  maxLines: 1,
                  style: typography.caption.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: AppIcons.copy,
            tooltip: l10n.helpAboutCopyLink,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                AppToast.success(context, message: l10n.helpAboutLinkCopied);
              }
            },
          ),
        ],
      ),
    );
  }
}
