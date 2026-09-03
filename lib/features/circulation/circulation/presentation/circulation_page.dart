import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/circulation/shared/domain/loan_status.dart';
import 'package:khulla/features/circulation/shared/presentation/circulation_labels.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/circulation_placeholder.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/loan_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/navigation_group.dart';
import 'package:khulla/shared/components/navigation_tile.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla/shared/widgets/collection_page_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The desk: what is out, what is due back, and what is late.
///
/// One page rather than a landing screen plus a list, because the loans table
/// *is* what a librarian came here to look at. The counts above it are the
/// filters written out — tapping *Overdue* selects the same rows the chip
/// does, which is the behaviour a stat tile earns by being tappable.
class CirculationPage extends StatefulWidget {
  const CirculationPage({super.key});

  @override
  State<CirculationPage> createState() => _CirculationPageState();
}

class _CirculationPageState extends State<CirculationPage> {
  String _query = '';
  LoanStatus? _status;
  AppTableSort _sort = const AppTableSort(columnId: 'due');

  bool get _isFiltered => _query.isNotEmpty || _status != null;

  void _clearFilters() => setState(() {
    _query = '';
    _status = null;
  });

  void _selectStatus(LoanStatus? status) => setState(() => _status = status);

  List<LoanRecord> get _matches {
    final needle = _query.trim().toLowerCase();
    final matches = [
      for (final loan in placeholderLoans)
        if ((needle.isEmpty ||
                loan.memberName.toLowerCase().contains(needle) ||
                loan.titleName.toLowerCase().contains(needle) ||
                loan.barcode.toLowerCase().contains(needle)) &&
            (_status == null || loan.status == _status))
          loan,
    ];

    return matches..sort((a, b) {
      final order = switch (_sort.columnId) {
        'member' => a.memberName.compareTo(b.memberName),
        'title' => a.titleName.compareTo(b.titleName),
        'issued' => a.issued.compareTo(b.issued),
        'fine' => a.accruedFine.compareTo(b.accruedFine),
        _ => a.due.compareTo(b.due),
      };
      return _sort.ascending ? order : -order;
    });
  }

  List<AppTableColumn<LoanRecord>> _columns(AppLocalizations l10n) {
    final scheme = context.colorScheme;
    final muted = context.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return [
      AppTableColumn<LoanRecord>(
        id: 'title',
        label: l10n.loansColumnTitle,
        flex: 4,
        sortable: true,
        cellBuilder: (context, loan) => Text(loan.titleName),
      ),
      AppTableColumn<LoanRecord>(
        id: 'member',
        label: l10n.loansColumnMember,
        flex: 3,
        sortable: true,
        showFrom: FormFactor.medium,
        cellBuilder: (context, loan) => Text(loan.memberName),
      ),
      AppTableColumn<LoanRecord>(
        id: 'barcode',
        label: l10n.loansColumnBarcode,
        flex: 2,
        showFrom: FormFactor.large,
        cellBuilder: (context, loan) => Text(loan.barcode, style: muted),
      ),
      AppTableColumn<LoanRecord>(
        id: 'issued',
        label: l10n.loansColumnIssued,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.large,
        cellBuilder: (context, loan) => Text(loan.issued, style: muted),
      ),
      AppTableColumn<LoanRecord>(
        id: 'due',
        label: l10n.loansColumnDue,
        flex: 2,
        sortable: true,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, loan) => Text(loan.due),
      ),
      AppTableColumn<LoanRecord>(
        id: 'fine',
        label: l10n.loansColumnFine,
        width: 100,
        sortable: true,
        alignment: Alignment.centerRight,
        showFrom: FormFactor.expanded,
        cellBuilder: (context, loan) => Text(
          loan.accruedFine.isZero
              ? l10n.commonNotSet
              : loan.accruedFine.display(),
          style: loan.accruedFine.isZero
              ? muted
              : context.textTheme.bodyMedium?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
      AppTableColumn<LoanRecord>(
        id: 'status',
        label: l10n.commonStatus,
        width: 120,
        cellBuilder: (context, loan) => AppStatusBadge(
          dense: true,
          label: loan.status.label(l10n),
          tone: loan.status.tone,
        ),
      ),
      AppTableColumn<LoanRecord>(
        id: 'actions',
        label: l10n.commonActions,
        width: 56,
        alignment: Alignment.centerRight,
        cellBuilder: (context, loan) => AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.loansReturn,
              icon: AppIcons.checkIn,
              onSelected: () => context.go(Routes.circulationReturn),
            ),
            AppMenuAction(
              label: l10n.loansRenew,
              icon: AppIcons.refresh,
              onSelected: () => showNotWiredToast(context),
            ),
            AppMenuAction(
              label: l10n.loansViewMember,
              icon: AppIcons.person,
              onSelected: () => context.go(Routes.member(loan.memberId)),
            ),
            AppMenuAction(
              label: l10n.loansMarkLost,
              icon: AppIcons.help,
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
    final spacing = context.appSpacing;
    final matches = _matches;

    return CollectionPageView<LoanRecord>(
      intro: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatStrip(
            tiles: [
              AppStatTile(
                label: l10n.circulationStatOnLoan,
                value: '${placeholderLoans.length}',
                icon: AppIcons.transfer,
                tone: AppStatusTone.brand,
                onTap: () => _selectStatus(null),
              ),
              AppStatTile(
                label: l10n.circulationStatDueToday,
                value: '${placeholderLoansWith(LoanStatus.dueToday).length}',
                icon: AppIcons.event,
                tone: AppStatusTone.warning,
                onTap: () => _selectStatus(LoanStatus.dueToday),
              ),
              AppStatTile(
                label: l10n.circulationStatOverdue,
                value: '${placeholderLoansWith(LoanStatus.overdue).length}',
                icon: AppIcons.error,
                tone: AppStatusTone.danger,
                onTap: () => _selectStatus(LoanStatus.overdue),
              ),
              AppStatTile(
                label: l10n.circulationStatHolds,
                value: '${placeholderReservations.length}',
                icon: AppIcons.bookmark,
                tone: AppStatusTone.info,
                onTap: () => context.go(Routes.circulationReservations),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          AppSectionHeader(
            title: l10n.circulationDeskTitle,
            subtitle: l10n.circulationDeskSubtitle,
          ),
          SizedBox(height: spacing.md),
          NavigationGroup(
            children: [
              NavigationTile(
                label: l10n.circulationCheckOut,
                description: l10n.checkOutSubtitle,
                icon: AppIcons.scan,
                route: Routes.circulationCheckOut,
              ),
              NavigationTile(
                label: l10n.circulationReturn,
                description: l10n.returnsSubtitle,
                icon: AppIcons.checkIn,
                route: Routes.circulationReturn,
              ),
              NavigationTile(
                label: l10n.circulationReservations,
                description: l10n.reservationsSubtitle,
                count: '${placeholderReservations.length}',
                icon: AppIcons.bookmark,
                route: Routes.circulationReservations,
              ),
              NavigationTile(
                label: l10n.circulationFines,
                description: l10n.finesSubtitle,
                count: placeholderOutstandingFines.display(),
                icon: AppIcons.wallet,
                route: Routes.circulationFines,
              ),
            ],
          ),
          SizedBox(height: spacing.lg),
          AppSectionHeader(
            title: l10n.circulationLoansTitle,
            subtitle: l10n.circulationLoansSubtitle,
          ),
        ],
      ),
      toolbar: AppToolbar(
        search: AppSearchField(
          hintText: l10n.circulationSearchHint,
          clearTooltip: l10n.commonClearSearch,
          onChanged: (value) => setState(() => _query = value),
        ),
        filters: [
          AppFilterChip(
            label: l10n.circulationFilterOnLoan,
            icon: AppIcons.transfer,
            selected: _status == LoanStatus.onLoan,
            onSelected: (selected) =>
                _selectStatus(selected ? LoanStatus.onLoan : null),
          ),
          AppFilterChip(
            label: l10n.circulationFilterDueToday,
            icon: AppIcons.event,
            tone: AppStatusTone.warning,
            selected: _status == LoanStatus.dueToday,
            onSelected: (selected) =>
                _selectStatus(selected ? LoanStatus.dueToday : null),
          ),
          AppFilterChip(
            label: l10n.circulationFilterOverdue,
            icon: AppIcons.error,
            tone: AppStatusTone.danger,
            selected: _status == LoanStatus.overdue,
            onSelected: (selected) =>
                _selectStatus(selected ? LoanStatus.overdue : null),
          ),
        ],
        actions: [
          if (_isFiltered)
            AppTextButton(
              onPressed: _clearFilters,
              child: Text(l10n.commonClearFilters),
            ),
          AppButton(
            size: AppButtonSize.medium,
            variant: AppButtonVariant.outline,
            onPressed: () => context.go(Routes.circulationReturn),
            child: Text(l10n.circulationReturn),
          ),
        ],
      ),
      items: matches,
      columns: _columns(l10n),
      sort: _sort,
      onSort: (next) => setState(() => _sort = next),
      onRowTap: (loan) => context.go(Routes.member(loan.memberId)),
      compactBuilder: (context, loan) => _LoanCard(loan: loan),
      emptyState: _isFiltered
          ? AppEmptyView(
              icon: AppIcons.noResults,
              title: l10n.commonNoMatchesTitle,
              message: l10n.commonNoMatchesBody,
              actionLabel: l10n.commonClearFilters,
              onAction: _clearFilters,
            )
          : AppEmptyView(
              icon: AppIcons.transfer,
              title: l10n.circulationLoansEmptyTitle,
              message: l10n.circulationLoansEmptyBody,
              actionLabel: l10n.circulationCheckOut,
              onAction: () => context.go(Routes.circulationCheckOut),
            ),
    );
  }
}

/// One loan as a card, for the window classes too narrow for eight columns.
class _LoanCard extends StatelessWidget {
  const _LoanCard({required this.loan});

  final LoanRecord loan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: () => context.go(Routes.member(loan.memberId)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    loan.titleName,
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
                  label: loan.status.label(l10n),
                  tone: loan.status.tone,
                ),
              ],
            ),
            SizedBox(height: spacing.xxs),
            Text(
              loan.memberName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xs),
            Text(
              loan.accruedFine.isZero
                  ? '${l10n.loansColumnDue} ${loan.due}'
                  : '${l10n.loansColumnDue} ${loan.due} · ${loan.accruedFine.display()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodySmall?.copyWith(
                color: loan.accruedFine.isZero
                    ? scheme.onSurfaceVariant
                    : scheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
