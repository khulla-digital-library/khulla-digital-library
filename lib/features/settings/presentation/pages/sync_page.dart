import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/sync_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Online sync: a second copy of the catalogue, somewhere else.
///
/// The screen is written to make one thing unmissable — the local database is
/// the source of truth and sync is a copy of it, never the other way round.
/// A librarian who believes the cloud is authoritative will eventually delete
/// the local file to "free space", and this app is the only place that record
/// exists.
class SyncPage extends StatefulWidget {
  const SyncPage({super.key});

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage> {
  SyncProvider _provider = SyncProvider.folder;
  bool _automatic = true;
  bool _encrypt = true;
  bool _unmeteredOnly = true;

  String _providerLabel(AppLocalizations l10n, SyncProvider provider) =>
      switch (provider) {
        SyncProvider.none => l10n.syncProviderNone,
        SyncProvider.folder => l10n.syncProviderFolder,
        SyncProvider.webdav => l10n.syncProviderWebdav,
        SyncProvider.s3 => l10n.syncProviderS3,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final connected = _provider != SyncProvider.none;

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverList.list(
              children: [
                AppPageHeader(
                  title: l10n.syncHeading,
                  onBackPressed: () => context.go(Routes.settings),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  l10n.syncSubtitle,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.textMuted,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: spacing.lg),
                AppCard(
                  tone: connected ? AppStatusTone.success : null,
                  child: Row(
                    children: [
                      Icon(
                        connected
                            ? Icons.cloud_done_outlined
                            : Icons.cloud_off_outlined,
                        color: connected ? colors.success : colors.textMuted,
                      ),
                      SizedBox(width: spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  l10n.syncStatusTitle,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.textMuted,
                                  ),
                                ),
                                SizedBox(width: spacing.xs),
                                AppStatusBadge(
                                  dense: true,
                                  tone: connected
                                      ? AppStatusTone.success
                                      : AppStatusTone.neutral,
                                  label: connected
                                      ? l10n.syncStatusConnected
                                      : l10n.syncStatusNever,
                                ),
                              ],
                            ),
                            SizedBox(height: spacing.xxs),
                            Text(
                              '${l10n.syncLastSynced}: $placeholderLastSynced'
                              ' · ${l10n.syncNextSync}: $placeholderNextSync',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.sm),
                      AppButton(
                        size: AppButtonSize.medium,
                        icon: Icons.sync_rounded,
                        onPressed: () => showNotWiredToast(context),
                        child: Text(l10n.syncNow),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
                SectionCard(
                  title: l10n.syncProviderTitle,
                  subtitle: l10n.syncProviderDescription,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppDropdownField<SyncProvider>(
                        label: l10n.syncProviderTitle,
                        value: _provider,
                        items: SyncProvider.values,
                        itemLabel: (provider) => _providerLabel(l10n, provider),
                        onChanged: (provider) => setState(
                          () => _provider = provider ?? SyncProvider.none,
                        ),
                      ),
                      SizedBox(height: spacing.md),
                      AppSwitchField(
                        label: l10n.syncAutoTitle,
                        description: l10n.syncAutoDescription,
                        value: _automatic,
                        onChanged: (value) =>
                            setState(() => _automatic = value),
                      ),
                      SizedBox(height: spacing.sm),
                      AppSwitchField(
                        label: l10n.syncEncryptTitle,
                        description: l10n.syncEncryptDescription,
                        value: _encrypt,
                        onChanged: (value) => setState(() => _encrypt = value),
                      ),
                      SizedBox(height: spacing.sm),
                      AppSwitchField(
                        label: l10n.syncWifiOnlyTitle,
                        description: l10n.syncWifiOnlyDescription,
                        value: _unmeteredOnly,
                        onChanged: (value) =>
                            setState(() => _unmeteredOnly = value),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: spacing.md),
                SectionCard(
                  title: l10n.syncHistoryTitle,
                  subtitle: l10n.syncHistorySubtitle,
                  child: placeholderSnapshots.isEmpty
                      ? AppEmptyView(
                          icon: Icons.cloud_off_outlined,
                          title: l10n.syncHistoryEmptyTitle,
                          message: l10n.syncHistoryEmptyBody,
                          variant: AppFeedbackVariant.inline,
                        )
                      : AppTable<SyncSnapshot>(
                          items: placeholderSnapshots,
                          rowHeight: 48,
                          columns: [
                            AppTableColumn<SyncSnapshot>(
                              id: 'when',
                              label: l10n.syncColumnWhen,
                              flex: 3,
                              cellBuilder: (context, snapshot) =>
                                  Text(snapshot.when),
                            ),
                            AppTableColumn<SyncSnapshot>(
                              id: 'size',
                              label: l10n.syncColumnSize,
                              flex: 2,
                              showFrom: FormFactor.medium,
                              cellBuilder: (context, snapshot) => Text(
                                snapshot.size,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                            AppTableColumn<SyncSnapshot>(
                              id: 'outcome',
                              label: l10n.syncColumnOutcome,
                              width: 130,
                              alignment: Alignment.centerRight,
                              cellBuilder: (context, snapshot) =>
                                  AppStatusBadge(
                                    dense: true,
                                    tone: snapshot.outcome.tone,
                                    label: switch (snapshot.outcome) {
                                      SyncOutcome.written => l10n.syncOutcomeOk,
                                      SyncOutcome.failed =>
                                        l10n.syncOutcomeFailed,
                                      SyncOutcome.skipped =>
                                        l10n.syncOutcomeSkipped,
                                    },
                                  ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
