import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/shared/domain/reservation_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/circulation_placeholder.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/reservation_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The hold queue, in the order members asked.
///
/// Ordering is the whole point of this screen, so the queue position is a
/// column rather than a detail: two members waiting on the same title is the
/// case the desk has to get right.
class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  String _query = '';
  ReservationStatus? _status;

  bool get _isFiltered => _query.isNotEmpty || _status != null;

  void _clearFilters() => setState(() {
    _query = '';
    _status = null;
  });

  List<ReservationRecord> get _matches {
    final needle = _query.trim().toLowerCase();
    return [
      for (final hold in placeholderReservations)
        if ((needle.isEmpty ||
                hold.memberName.toLowerCase().contains(needle) ||
                hold.titleName.toLowerCase().contains(needle)) &&
            (_status == null || hold.status == _status))
          hold,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;
    final matches = _matches;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return CollectionPageView<ReservationRecord>(
      header: CollectionHeader(
        title: l10n.reservationsHeading,
        subtitle: l10n.reservationsSubtitle,
        actionLabel: l10n.reservationsPlace,
        onAction: () => showNotWiredToast(context),
        leading: AppPageHeader(
          title: l10n.circulationHeading,
          onBackPressed: () => context.go(Routes.circulation),
        ),
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.reservationsSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() => _query = value),
        ),
        filters: [
          for (final status in ReservationStatus.values)
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
      onRowTap: (hold) => context.go(Routes.catalogTitle(hold.titleId)),
      compactBuilder: (context, hold) => _ReservationCard(hold: hold),
      columns: [
        AppTableColumn<ReservationRecord>(
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
        AppTableColumn<ReservationRecord>(
          id: 'title',
          label: l10n.reservationsColumnTitle,
          flex: 4,
          cellBuilder: (context, hold) => Text(hold.titleName),
        ),
        AppTableColumn<ReservationRecord>(
          id: 'member',
          label: l10n.reservationsColumnMember,
          flex: 3,
          showFrom: FormFactor.medium,
          cellBuilder: (context, hold) => Text(hold.memberName),
        ),
        AppTableColumn<ReservationRecord>(
          id: 'placed',
          label: l10n.reservationsColumnPlaced,
          flex: 2,
          showFrom: FormFactor.large,
          cellBuilder: (context, hold) => Text(hold.placed, style: muted),
        ),
        AppTableColumn<ReservationRecord>(
          id: 'expires',
          label: l10n.reservationsColumnExpires,
          flex: 2,
          showFrom: FormFactor.expanded,
          cellBuilder: (context, hold) =>
              Text(hold.expires ?? l10n.commonNotSet, style: muted),
        ),
        AppTableColumn<ReservationRecord>(
          id: 'status',
          label: l10n.commonStatus,
          width: 150,
          cellBuilder: (context, hold) => AppStatusBadge(
            dense: true,
            label: hold.status.label(l10n),
            tone: hold.status.tone,
          ),
        ),
        AppTableColumn<ReservationRecord>(
          id: 'actions',
          label: l10n.commonActions,
          width: 56,
          alignment: Alignment.centerRight,
          cellBuilder: (context, hold) => AppMenuButton(
            tooltip: l10n.commonMoreActions,
            actions: [
              AppMenuAction(
                label: l10n.reservationsMarkReady,
                icon: Icons.notifications_active_outlined,
                onSelected: () => showNotWiredToast(context),
              ),
              AppMenuAction(
                label: l10n.loansViewMember,
                icon: Icons.person_outline_rounded,
                onSelected: () => context.go(Routes.member(hold.memberId)),
              ),
              AppMenuAction(
                label: l10n.reservationsCancel,
                icon: Icons.close_rounded,
                isDestructive: true,
                onSelected: () => showNotWiredToast(context),
              ),
            ],
          ),
        ),
      ],
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: Icons.bookmark_border_rounded,
              title: l10n.reservationsEmptyTitle,
              message: l10n.reservationsEmptyBody,
              actionLabel: l10n.reservationsPlace,
              onAction: () => showNotWiredToast(context),
            ),
    );
  }
}

/// One hold as a card, for a compact window.
class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.hold});

  final ReservationRecord hold;

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
                    hold.titleName,
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
              hold.memberName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              '${l10n.reservationsQueuePosition('${hold.queuePosition}')} · ${hold.placed}',
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
