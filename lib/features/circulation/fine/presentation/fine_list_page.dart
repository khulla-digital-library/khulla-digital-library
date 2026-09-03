import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/circulation_placeholder.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/fine_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The fines ledger: what is owed, what was taken, what was written off.
///
/// Every amount on this screen is a `Money` rendered through `display()` —
/// never interpolated, which would print the paisa, and never formatted by
/// hand, which would put the currency symbol somewhere the library's settings
/// did not ask for.
class FineListPage extends StatefulWidget {
  const FineListPage({super.key});

  @override
  State<FineListPage> createState() => _FineListPageState();
}

class _FineListPageState extends State<FineListPage> {
  String _query = '';
  FineStatus? _status;

  bool get _isFiltered => _query.isNotEmpty || _status != null;

  void _clearFilters() => setState(() {
    _query = '';
    _status = null;
  });

  List<FineRecord> get _matches {
    final needle = _query.trim().toLowerCase();
    return [
      for (final fine in placeholderFines)
        if ((needle.isEmpty ||
                fine.memberName.toLowerCase().contains(needle) ||
                (fine.titleName?.toLowerCase().contains(needle) ?? false)) &&
            (_status == null || fine.status == _status))
          fine,
    ];
  }

  Future<void> _collect(FineRecord fine) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: l10n.finesCollectTitle,
      message: l10n.finesCollectBody(fine.amount.display(), fine.memberName),
      icon: AppIcons.wallet,
      actionsBuilder: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.finesCollect),
            ),
          ),
          SizedBox(height: dialogContext.appSpacing.xs),
          AppDialog.secondaryAction(
            context: dialogContext,
            label: l10n.commonCancel,
            onPressed: () => Navigator.of(dialogContext).pop(false),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    showNotWiredToast(context);
  }

  Future<void> _waive(FineRecord fine) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.finesWaiveTitle,
      message: l10n.finesWaiveBody,
      confirmLabel: l10n.finesWaive,
      cancelLabel: l10n.commonCancel,
      icon: AppIcons.waiveFine,
    );
    if (!mounted || !confirmed) return;
    showNotWiredToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final matches = _matches;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final owing = {
      for (final fine in placeholderFines)
        if (fine.status == FineStatus.unpaid) fine.memberId,
    }.length;

    return CollectionPageView<FineRecord>(
      summary: l10n.finesSubtitle,
      intro: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatStrip(
            tiles: [
              AppStatTile(
                label: l10n.finesStatOutstanding,
                value: placeholderOutstandingFines.display(),
                icon: AppIcons.wallet,
                tone: AppStatusTone.danger,
              ),
              AppStatTile(
                label: l10n.finesStatCollected,
                value: placeholderCollectedFines.display(),
                icon: AppIcons.payment,
                tone: AppStatusTone.success,
              ),
              AppStatTile(
                label: l10n.finesStatWaived,
                value: placeholderWaivedFines.display(),
                icon: AppIcons.waiveFine,
              ),
              AppStatTile(
                label: l10n.finesStatMembersOwing,
                value: '$owing',
                icon: AppIcons.people,
                tone: AppStatusTone.warning,
              ),
            ],
          ),
        ],
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.finesSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() => _query = value),
        ),
        filters: [
          for (final status in FineStatus.values)
            AppFilterChip(
              label: status.label(l10n),
              tone: status.tone,
              selected: _status == status,
              onSelected: (selected) =>
                  setState(() => _status = selected ? status : null),
            ),
        ],
        actions: [
          if (_isFiltered)
            AppTextButton(
              onPressed: _clearFilters,
              child: Text(l10n.commonClearFilters),
            ),
        ],
      ),
      items: matches,
      onRowTap: (fine) => context.go(Routes.member(fine.memberId)),
      compactBuilder: (context, fine) => _FineCard(fine: fine),
      columns: [
        AppTableColumn<FineRecord>(
          id: 'member',
          label: l10n.finesColumnMember,
          flex: 3,
          cellBuilder: (context, fine) => Text(fine.memberName),
        ),
        AppTableColumn<FineRecord>(
          id: 'reason',
          label: l10n.finesColumnReason,
          flex: 2,
          showFrom: FormFactor.medium,
          cellBuilder: (context, fine) => Row(
            children: [
              AppIcon(
                fine.reason.icon,
                size: spacing.md,
                color: scheme.onSurfaceVariant,
              ),
              SizedBox(width: spacing.xs),
              Flexible(child: Text(fine.reason.label(l10n))),
            ],
          ),
        ),
        AppTableColumn<FineRecord>(
          id: 'title',
          label: l10n.finesColumnTitle,
          flex: 3,
          showFrom: FormFactor.large,
          cellBuilder: (context, fine) =>
              Text(fine.titleName ?? l10n.commonNotSet, style: muted),
        ),
        AppTableColumn<FineRecord>(
          id: 'raised',
          label: l10n.finesColumnRaised,
          flex: 2,
          showFrom: FormFactor.expanded,
          cellBuilder: (context, fine) => Text(fine.raised, style: muted),
        ),
        AppTableColumn<FineRecord>(
          id: 'amount',
          label: l10n.finesColumnAmount,
          width: 110,
          alignment: Alignment.centerRight,
          cellBuilder: (context, fine) => Text(
            fine.amount.display(),
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: fine.status == FineStatus.unpaid
                  ? scheme.error
                  : scheme.onSurface,
            ),
          ),
        ),
        AppTableColumn<FineRecord>(
          id: 'status',
          label: l10n.commonStatus,
          width: 110,
          cellBuilder: (context, fine) => AppStatusBadge(
            dense: true,
            label: fine.status.label(l10n),
            tone: fine.status.tone,
          ),
        ),
        AppTableColumn<FineRecord>(
          id: 'actions',
          label: l10n.commonActions,
          width: 56,
          alignment: Alignment.centerRight,
          cellBuilder: (context, fine) => AppMenuButton(
            tooltip: l10n.commonMoreActions,
            actions: [
              AppMenuAction(
                label: l10n.finesCollect,
                icon: AppIcons.payment,
                enabled: fine.status == FineStatus.unpaid,
                onSelected: () => unawaited(_collect(fine)),
              ),
              AppMenuAction(
                label: l10n.loansViewMember,
                icon: AppIcons.person,
                onSelected: () => context.go(Routes.member(fine.memberId)),
              ),
              AppMenuAction(
                label: l10n.finesWaive,
                icon: AppIcons.waiveFine,
                isDestructive: true,
                enabled: fine.status == FineStatus.unpaid,
                onSelected: () => unawaited(_waive(fine)),
              ),
            ],
          ),
        ),
      ],
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: AppIcons.noResults,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: AppIcons.wallet,
              title: l10n.finesEmptyTitle,
              message: l10n.finesEmptyBody,
            ),
    );
  }
}

/// One fine as a card, for a compact window.
class _FineCard extends StatelessWidget {
  const _FineCard({required this.fine});

  final FineRecord fine;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: () => context.go(Routes.member(fine.memberId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    fine.memberName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  fine.amount.display(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: fine.status == FineStatus.unpaid
                        ? scheme.error
                        : scheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.xxs),
            Text(
              fine.titleName ?? fine.reason.label(l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Row(
              children: [
                AppStatusBadge(
                  dense: true,
                  label: fine.status.label(l10n),
                  tone: fine.status.tone,
                ),
                SizedBox(width: spacing.xs),
                Flexible(
                  child: Text(
                    fine.raised,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
