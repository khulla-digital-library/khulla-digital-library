import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/fine/domain/models/fine.dart';
import 'package:khulla/features/circulation/fine/presentation/cubit/fine_list_cubit.dart';
import 'package:khulla/features/circulation/fine/presentation/cubit/fine_list_state.dart';
import 'package:khulla/features/circulation/shared/domain/fine_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The fines ledger: what is owed, what was taken, what was written off.
class FineListPage extends StatelessWidget {
  const FineListPage({super.key});

  bool _isFiltered(FineListState state) =>
      state.query.search.isNotEmpty || state.query.status != null;

  Future<void> _collect(BuildContext context, Fine fine) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.show<bool>(
      context: context,
      title: l10n.finesCollectTitle,
      message: l10n.finesCollectBody(
        fine.outstanding.display(),
        fine.memberName ?? l10n.commonNotSet,
      ),
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
    if (!context.mounted || confirmed != true) return;
    showNotWiredToast(context);
  }

  Future<void> _waive(BuildContext context, Fine fine) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.finesWaiveTitle,
      message: l10n.finesWaiveBody,
      confirmLabel: l10n.finesWaive,
      cancelLabel: l10n.commonCancel,
      icon: AppIcons.waiveFine,
    );
    if (!context.mounted || !confirmed) return;
    showNotWiredToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final cubit = context.read<FineListCubit>();
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return BlocBuilder<FineListCubit, FineListState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadFines,
          );
        }

        final isFiltered = _isFiltered(state);

        return CollectionPageView<Fine>(
          summary: l10n.finesSubtitle,
          intro: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppStatStrip(
                tiles: [
                  AppStatTile(
                    label: l10n.finesStatOutstanding,
                    value: state.outstandingTotal.display(),
                    icon: AppIcons.wallet,
                    tone: AppStatusTone.danger,
                  ),
                  AppStatTile(
                    label: l10n.finesStatCollected,
                    value: state.collectedTotal.display(),
                    icon: AppIcons.payment,
                    tone: AppStatusTone.success,
                  ),
                  AppStatTile(
                    label: l10n.finesStatWaived,
                    value: state.waivedTotal.display(),
                    icon: AppIcons.waiveFine,
                  ),
                  AppStatTile(
                    label: l10n.finesStatMembersOwing,
                    value: '${state.membersOwing}',
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
              onChanged: cubit.searchChanged,
            ),
            filters: [
              for (final status in FineStatus.values)
                AppFilterChip(
                  label: status.label(l10n),
                  tone: status.tone,
                  selected: state.query.status == status,
                  onSelected: (selected) =>
                      cubit.statusFilterChanged(selected ? status : null),
                ),
            ],
            actions: [
              if (isFiltered)
                AppTextButton(
                  onPressed: cubit.clearFilters,
                  child: Text(l10n.commonClearFilters),
                ),
            ],
          ),
          items: state.fines,
          onRowTap: (fine) => context.go(Routes.member(fine.memberId)),
          compactBuilder: (context, fine) => _FineCard(fine: fine),
          columns: [
            AppTableColumn<Fine>(
              id: 'member',
              label: l10n.finesColumnMember,
              flex: 3,
              cellBuilder: (context, fine) =>
                  Text(fine.memberName ?? l10n.commonNotSet),
            ),
            AppTableColumn<Fine>(
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
            AppTableColumn<Fine>(
              id: 'title',
              label: l10n.finesColumnTitle,
              flex: 3,
              showFrom: FormFactor.large,
              cellBuilder: (context, fine) =>
                  Text(fine.titleName ?? l10n.commonNotSet, style: muted),
            ),
            AppTableColumn<Fine>(
              id: 'raised',
              label: l10n.finesColumnRaised,
              flex: 2,
              showFrom: FormFactor.expanded,
              cellBuilder: (context, fine) => Text(fine.raisedOn, style: muted),
            ),
            AppTableColumn<Fine>(
              id: 'amount',
              label: l10n.finesColumnAmount,
              width: 110,
              alignment: Alignment.centerRight,
              cellBuilder: (context, fine) => Text(
                fine.outstanding.display(),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: fine.status == FineStatus.unpaid
                      ? scheme.error
                      : scheme.onSurface,
                ),
              ),
            ),
            AppTableColumn<Fine>(
              id: 'status',
              label: l10n.commonStatus,
              width: 110,
              cellBuilder: (context, fine) => AppStatusBadge(
                dense: true,
                label: fine.status.label(l10n),
                tone: fine.status.tone,
              ),
            ),
            AppTableColumn<Fine>(
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
                    onSelected: () => unawaited(_collect(context, fine)),
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
                    onSelected: () => unawaited(_waive(context, fine)),
                  ),
                ],
              ),
            ),
          ],
          emptyState: isFiltered
              ? AppEmptyView(
                  icon: AppIcons.noResults,
                  title: l10n.commonNoMatchesTitle,
                  message: l10n.commonNoMatchesBody,
                  actionLabel: l10n.commonClearFilters,
                  onAction: cubit.clearFilters,
                )
              : AppEmptyView(
                  icon: AppIcons.wallet,
                  title: l10n.finesEmptyTitle,
                  message: l10n.finesEmptyBody,
                ),
        );
      },
    );
  }
}

class _FineCard extends StatelessWidget {
  const _FineCard({required this.fine});

  final Fine fine;

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
                    fine.memberName ?? l10n.commonNotSet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  fine.outstanding.display(),
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
                    fine.raisedOn,
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
