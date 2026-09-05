import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/reservation/domain/models/reservation.dart';
import 'package:khulla/features/circulation/reservation/presentation/cubit/reservation_list_cubit.dart';
import 'package:khulla/features/circulation/reservation/presentation/cubit/reservation_list_state.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The hold queue, in the order members asked.
class ReservationListPage extends StatelessWidget {
  const ReservationListPage({super.key});

  bool _isFiltered(ReservationListState state) =>
      state.query.search.isNotEmpty || state.query.status != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;
    final cubit = context.read<ReservationListCubit>();
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return BlocBuilder<ReservationListCubit, ReservationListState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: cubit.loadReservations,
          );
        }

        final isFiltered = _isFiltered(state);

        return CollectionPageView<Reservation>(
          summary: l10n.reservationsSubtitle,
          toolbar: AppToolbar(
            search: AppSearchField(
              hintText: l10n.reservationsSearchHint,
              clearTooltip: l10n.commonClearSearch,
              onChanged: cubit.searchChanged,
            ),
            filters: [
              for (final status in ReservationStatus.values)
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
          items: state.reservations,
          onRowTap: (hold) => context.go(Routes.catalogTitle(hold.titleId)),
          compactBuilder: (context, hold) => _ReservationCard(hold: hold),
          columns: [
            AppTableColumn<Reservation>(
              id: 'queue',
              label: l10n.reservationsColumnQueue,
              width: 72,
              cellBuilder: (context, hold) => Text(
                l10n.reservationsQueuePosition('${hold.queuePosition}'),
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            AppTableColumn<Reservation>(
              id: 'title',
              label: l10n.reservationsColumnTitle,
              flex: 4,
              cellBuilder: (context, hold) =>
                  Text(hold.titleName ?? l10n.commonNotSet),
            ),
            AppTableColumn<Reservation>(
              id: 'member',
              label: l10n.reservationsColumnMember,
              flex: 3,
              showFrom: FormFactor.medium,
              cellBuilder: (context, hold) =>
                  Text(hold.memberName ?? l10n.commonNotSet),
            ),
            AppTableColumn<Reservation>(
              id: 'placed',
              label: l10n.reservationsColumnPlaced,
              flex: 2,
              showFrom: FormFactor.large,
              cellBuilder: (context, hold) => Text(hold.placedOn, style: muted),
            ),
            AppTableColumn<Reservation>(
              id: 'expires',
              label: l10n.reservationsColumnExpires,
              flex: 2,
              showFrom: FormFactor.expanded,
              cellBuilder: (context, hold) =>
                  Text(hold.expiresOn ?? l10n.commonNotSet, style: muted),
            ),
            AppTableColumn<Reservation>(
              id: 'status',
              label: l10n.commonStatus,
              width: 150,
              cellBuilder: (context, hold) => AppStatusBadge(
                dense: true,
                label: hold.status.label(l10n),
                tone: hold.status.tone,
              ),
            ),
            AppTableColumn<Reservation>(
              id: 'actions',
              label: l10n.commonActions,
              width: 56,
              alignment: Alignment.centerRight,
              cellBuilder: (context, hold) => AppMenuButton(
                tooltip: l10n.commonMoreActions,
                actions: [
                  AppMenuAction(
                    label: l10n.reservationsMarkReady,
                    icon: AppIcons.notificationsActive,
                    onSelected: () => showNotWiredToast(context),
                  ),
                  AppMenuAction(
                    label: l10n.loansViewMember,
                    icon: AppIcons.person,
                    onSelected: () => context.go(Routes.member(hold.memberId)),
                  ),
                  AppMenuAction(
                    label: l10n.reservationsCancel,
                    icon: AppIcons.close,
                    isDestructive: true,
                    onSelected: () => showNotWiredToast(context),
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
                  icon: AppIcons.bookmark,
                  title: l10n.reservationsEmptyTitle,
                  message: l10n.reservationsEmptyBody,
                  actionLabel: l10n.reservationsPlace,
                  onAction: () => showNotWiredToast(context),
                ),
        );
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.hold});

  final Reservation hold;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: () => context.go(Routes.catalogTitle(hold.titleId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hold.titleName ?? l10n.commonNotSet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                AppStatusBadge(
                  dense: true,
                  label: hold.status.label(l10n),
                  tone: hold.status.tone,
                ),
              ],
            ),
            SizedBox(height: spacing.xxs),
            Text(
              hold.memberName ?? l10n.commonNotSet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              '${l10n.reservationsQueuePosition('${hold.queuePosition}')} · ${hold.placedOn}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
