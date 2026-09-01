import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/members/domain/member_status.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/placeholder/member_record.dart';
import 'package:khulla/features/members/presentation/placeholder/members_placeholder.dart';
import 'package:khulla/features/members/presentation/widgets/member_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The register: every borrower and how they stand.
///
/// The filters are the questions a desk actually asks of it — who is holding
/// something, who owes something, whose card has stopped working — rather
/// than one chip per enum value.
class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  static const int _pageSize = 8;

  String _query = '';
  bool _withLoans = false;
  bool _owesFines = false;
  bool _suspended = false;
  bool _expiring = false;
  AppTableSort _sort = const AppTableSort(columnId: 'name');
  int _page = 0;

  bool get _isFiltered =>
      _query.isNotEmpty || _withLoans || _owesFines || _suspended || _expiring;

  void _clearFilters() => setState(() {
    _query = '';
    _withLoans = false;
    _owesFines = false;
    _suspended = false;
    _expiring = false;
    _page = 0;
  });

  List<MemberRecord> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final member in placeholderMembers)
        if ((needle.isEmpty ||
                member.name.toLowerCase().contains(needle) ||
                member.cardNumber.toLowerCase().contains(needle) ||
                (member.phone?.contains(needle) ?? false)) &&
            (!_withLoans || member.loansOut > 0) &&
            (!_owesFines || member.finesOwed.isPositive) &&
            (!_suspended || member.status == MemberStatus.suspended) &&
            (!_expiring || member.status == MemberStatus.expiring))
          member,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'card' => a.cardNumber.compareTo(b.cardNumber),
        'loans' => a.loansOut.compareTo(b.loansOut),
        'fines' => a.finesOwed.compareTo(b.finesOwed),
        'joined' => a.joined.compareTo(b.joined),
        'expires' => a.expires.compareTo(b.expires),
        _ => a.name.compareTo(b.name),
      };
      return _sort.ascending ? order : -order;
    });
  }

  List<AppTableColumn<MemberRecord>> _columns(AppLocalizations l10n) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<MemberRecord>(
        id: 'name',
        label: l10n.membersColumnName,
        flex: 4,
        sortable: true,
        cellBuilder: (context, member) => Row(
          children: [
            AppAvatar(initials: member.initials, size: 28),
            SizedBox(width: spacing.xs),
            Flexible(child: Text(member.name)),
          ],
        ),
      ),
      AppTableColumn<MemberRecord>(
        id: 'card',
        label: l10n.membersColumnCard,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, member) => Text(member.cardNumber, style: muted),
      ),
      AppTableColumn<MemberRecord>(
        id: 'category',
        label: l10n.membersColumnCategory,
        flex: 2,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, member) => Row(
          children: [
            Icon(
              member.category.icon,
              size: spacing.md,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(width: spacing.xs),
            Flexible(child: Text(member.category.label(l10n))),
          ],
        ),
      ),
      AppTableColumn<MemberRecord>(
        id: 'loans',
        label: l10n.membersColumnLoans,
        width: 90,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.medium,
        cellBuilder: (context, member) => Text(
          '${member.loansOut}',
          style: member.overdue > 0
              ? context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                )
              : null,
        ),
      ),
      AppTableColumn<MemberRecord>(
        id: 'fines',
        label: l10n.membersColumnFines,
        width: 110,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, member) => Text(
          member.finesOwed.isZero
              ? l10n.commonNotSet
              : member.finesOwed.display(),
          style: member.finesOwed.isZero
              ? muted
              : context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
      AppTableColumn<MemberRecord>(
        id: 'expires',
        label: l10n.membersColumnExpires,
        flex: 2,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.large,
        cellBuilder: (context, member) => Text(member.expires, style: muted),
      ),
      AppTableColumn<MemberRecord>(
        id: 'status',
        label: l10n.commonStatus,
        width: 130,
        cellBuilder: (context, member) => AppStatusBadge(
          dense: true,
          label: member.status.label(l10n),
          tone: member.status.tone,
        ),
      ),
      AppTableColumn<MemberRecord>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, member) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.memberDetailCheckOut,
              icon: Icons.qr_code_scanner_rounded,
              onSelected: () => context.go(Routes.circulationCheckOut),
            ),
            AppMenuAction(
              label: l10n.memberDetailEdit,
              icon: Icons.edit_outlined,
              onSelected: () => context.go(Routes.memberEdit(member.id)),
            ),
            AppMenuAction(
              label: l10n.memberDetailRenewMembership,
              icon: Icons.autorenew_rounded,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.memberDetailSuspend,
              icon: Icons.block_rounded,
              isDestructive: true,
              onSelected: () => showNotWiredToast(context),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final matches = _matches;
    final pageCount = (matches.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount == 0 ? 0 : pageCount - 1);
    final start = page * _pageSize;
    final end = (start + _pageSize).clamp(0, matches.length);

    return CollectionPageView<MemberRecord>(
      header: CollectionHeader(
        title: l10n.membersHeading,
        subtitle: l10n.membersSubtitle('${placeholderMembers.length}'),
        actionLabel: l10n.membersAdd,
        onAction: () => context.go(Routes.memberNew),
        menuTooltip: l10n.commonMoreActions,
        menuActions: [
          AppMenuAction(
            label: l10n.membersImport,
            icon: Icons.file_upload_outlined,
            onSelected: () => showNotWiredToast(context),
          ),
          AppMenuAction(
            label: l10n.membersExport,
            icon: Icons.file_download_outlined,
            onSelected: () => showNotWiredToast(context),
          ),
        ],
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.membersSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() {
            _query = value;
            _page = 0;
          }),
        ),
        filters: [
          AppFilterChip(
            label: l10n.membersFilterWithLoans,
            icon: Icons.swap_horiz_rounded,
            selected: _withLoans,
            onSelected: (selected) => setState(() {
              _withLoans = selected;
              _page = 0;
            }),
          ),
          AppFilterChip(
            label: l10n.membersFilterOwesFines,
            icon: Icons.account_balance_wallet_outlined,
            tone: AppStatusTone.danger,
            selected: _owesFines,
            onSelected: (selected) => setState(() {
              _owesFines = selected;
              _page = 0;
            }),
          ),
          AppFilterChip(
            label: l10n.membersFilterExpiring,
            icon: Icons.schedule_rounded,
            tone: AppStatusTone.warning,
            selected: _expiring,
            onSelected: (selected) => setState(() {
              _expiring = selected;
              _page = 0;
            }),
          ),
          AppFilterChip(
            label: l10n.membersFilterSuspended,
            icon: Icons.block_rounded,
            tone: AppStatusTone.danger,
            selected: _suspended,
            onSelected: (selected) => setState(() {
              _suspended = selected;
              _page = 0;
            }),
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
      items: matches.sublist(start, end),
      columns: _columns(l10n),
      sort: _sort,
      onSort: (next) => setState(() {
        _sort = next;
        _page = 0;
      }),
      onRowTap: (member) => context.go(Routes.member(member.id)),
      compactBuilder: (context, member) => MemberCard(
        member: member,
        onTap: () => context.go(Routes.member(member.id)),
      ),
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: Icons.people_outline_rounded,
              title: l10n.membersEmptyTitle,
              message: l10n.membersEmptyBody,
              actionLabel: l10n.membersAdd,
              onAction: () => context.go(Routes.memberNew),
            ),
      footer: AppPagination(
        rangeLabel: l10n.commonRangeLabel(
          '${start + 1}',
          '$end',
          '${matches.length}',
        ),
        previousTooltip: l10n.commonPreviousPage,
        nextTooltip: l10n.commonNextPage,
        onPrevious: page == 0 ? null : () => setState(() => _page = page - 1),
        onNext: page >= pageCount - 1
            ? null
            : () => setState(() => _page = page + 1),
      ),
    );
  }
}
