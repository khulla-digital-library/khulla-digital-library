import 'package:khulla/features/users/domain/user_status.dart';
import 'package:khulla/features/users/presentation/placeholder/staff_record.dart';
import 'package:khulla/features/users/presentation/placeholder/users_placeholder.dart';
import 'package:khulla/features/users/presentation/user_labels.dart';
import 'package:khulla/features/users/presentation/widgets/staff_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Who can sign in to this library, and as what.
///
/// A single-branch library still wants this screen: the ledger is only worth
/// something if it can say *which* member of staff waived a fine, and that
/// means one account per person rather than a shared login taped to the
/// monitor.
class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  static const int _pageSize = 8;

  String _query = '';
  final Set<UserStatus> _statuses = <UserStatus>{};
  AppTableSort _sort = const AppTableSort(columnId: 'name');
  int _page = 0;

  bool get _isFiltered => _query.isNotEmpty || _statuses.isNotEmpty;

  void _clearFilters() => setState(() {
    _query = '';
    _statuses.clear();
    _page = 0;
  });

  void _toggleStatus(UserStatus status, bool selected) => setState(() {
    if (selected) {
      _statuses.add(status);
    } else {
      _statuses.remove(status);
    }
    _page = 0;
  });

  List<StaffRecord> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final staff in placeholderStaff)
        if ((needle.isEmpty ||
                staff.name.toLowerCase().contains(needle) ||
                staff.email.toLowerCase().contains(needle)) &&
            (_statuses.isEmpty || _statuses.contains(staff.status)))
          staff,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'email' => a.email.compareTo(b.email),
        'role' => a.role.index.compareTo(b.role.index),
        'status' => a.status.index.compareTo(b.status.index),
        _ => a.name.compareTo(b.name),
      };
      return _sort.ascending ? order : -order;
    });
  }

  List<AppTableColumn<StaffRecord>> _columns(AppLocalizations l10n) {
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: colors.textMuted,
    );

    return [
      AppTableColumn<StaffRecord>(
        id: 'name',
        label: l10n.usersColumnName,
        flex: 4,
        sortable: true,
        cellBuilder: (context, staff) => Row(
          children: [
            AppAvatar(initials: staff.initials, size: 32),
            SizedBox(width: spacing.xs + 2),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    staff.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.textHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    staff.email,
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
      AppTableColumn<StaffRecord>(
        id: 'role',
        label: l10n.usersColumnRole,
        flex: 3,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, staff) => Row(
          children: [
            AppIcon(
              staff.role.icon,
              size: spacing.md,
              color: staff.role.tone.foreground(context),
            ),
            SizedBox(width: spacing.xs),
            Flexible(child: Text(staff.role.label(l10n))),
          ],
        ),
      ),
      AppTableColumn<StaffRecord>(
        id: 'lastActive',
        label: l10n.usersColumnLastActive,
        flex: 3,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, staff) => Text(
          staff.lastActive ?? l10n.usersNeverSignedIn,
          style: muted,
        ),
      ),
      AppTableColumn<StaffRecord>(
        id: 'status',
        label: l10n.commonStatus,
        width: 130,
        sortable: true,
        cellBuilder: (context, staff) => AppStatusBadge(
          dense: true,
          label: staff.status.label(l10n),
          tone: staff.status.tone,
        ),
      ),
      AppTableColumn<StaffRecord>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, staff) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.usersEditRole,
              icon: AppIcons.idCard,
              onSelected: () => showNotWiredToast(context),
            ),
            if (staff.status == UserStatus.invited)
              AppMenuAction(
                label: l10n.usersResendInvite,
                icon: AppIcons.email,
                onSelected: () => showNotWiredToast(context),
              ),
            AppMenuAction(
              label: l10n.usersResetPassword,
              icon: AppIcons.resetPassword,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: staff.status == UserStatus.disabled
                  ? l10n.usersEnable
                  : l10n.usersDisable,
              icon: AppIcons.blocked,
              isDestructive: staff.status != UserStatus.disabled,
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

    return CollectionPageView<StaffRecord>(
      summary: l10n.usersSubtitle('${placeholderStaff.length}'),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.usersSearchHint,
          clearTooltip: l10n.commonClearSearch,
          dense: true,
          onChanged: (value) => setState(() {
            _query = value;
            _page = 0;
          }),
        ),
        filters: [
          AppFilterChip(
            label: l10n.usersFilterActive,
            selected: _statuses.contains(UserStatus.active),
            tone: AppStatusTone.success,
            onSelected: (selected) =>
                _toggleStatus(UserStatus.active, selected),
          ),
          AppFilterChip(
            label: l10n.usersFilterInvited,
            selected: _statuses.contains(UserStatus.invited),
            tone: AppStatusTone.warning,
            onSelected: (selected) =>
                _toggleStatus(UserStatus.invited, selected),
          ),
          AppFilterChip(
            label: l10n.usersFilterDisabled,
            selected: _statuses.contains(UserStatus.disabled),
            onSelected: (selected) =>
                _toggleStatus(UserStatus.disabled, selected),
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
      onRowTap: (_) => showNotWiredToast(context),
      compactBuilder: (context, staff) => StaffCard(staff: staff),
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: AppIcons.noResults,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: AppIcons.idCard,
              title: l10n.usersEmptyTitle,
              message: l10n.usersEmptyBody,
              actionLabel: l10n.usersAdd,
              onAction: () => showNotWiredToast(context),
            ),
      footer: AppPagination(
        rangeLabel: l10n.commonShowingRange(
          '${start + 1}',
          '$end',
          '${matches.length}',
        ),
        previousTooltip: l10n.commonPreviousPage,
        nextTooltip: l10n.commonNextPage,
        pageCount: pageCount,
        currentPage: page,
        onPageSelected: (next) => setState(() => _page = next),
        onPrevious: page == 0 ? null : () => setState(() => _page = page - 1),
        onNext: page >= pageCount - 1
            ? null
            : () => setState(() => _page = page + 1),
      ),
    );
  }
}
