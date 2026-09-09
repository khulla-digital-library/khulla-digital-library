import 'package:khulla_ui/khulla_ui.dart';

/// The gallery's data section: table and pagination.
///
/// Owns its demo page state and the demo loan rows so the gallery shell
/// stays a thin section switch.
class AppGalleryData extends StatefulWidget {
  const AppGalleryData({super.key});

  @override
  State<AppGalleryData> createState() => _AppGalleryDataState();
}

class _AppGalleryDataState extends State<AppGalleryData> {
  int _page = 2;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppGalleryStack(
      children: [
        AppGallerySection(
          title: 'Table',
          note:
              'Zebra on even rows, a tint on hover, a warmer tint on the '
              'selected one. Hover a sortable header to reveal its chevron.',
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: colors.hairline),
                borderRadius: BorderRadius.circular(
                  context.appRadius.container,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  context.appRadius.container,
                ),
                child: AppTable<AppGalleryLoan>(
                  items: _demoLoans,
                  onRowTap: (_) {},
                  isSelected: (loan) =>
                      loan.title.startsWith('The Dispossessed'),
                  sort: const AppTableSort(columnId: 'due'),
                  onSort: (_) {},
                  columns: [
                    AppTableColumn<AppGalleryLoan>(
                      id: 'title',
                      label: 'Title',
                      flex: 3,
                      sortable: true,
                      cellBuilder: (context, loan) => Text(loan.title),
                    ),
                    AppTableColumn<AppGalleryLoan>(
                      id: 'member',
                      label: 'Member',
                      flex: 2,
                      cellBuilder: (context, loan) => Text(loan.member),
                    ),
                    AppTableColumn<AppGalleryLoan>(
                      id: 'due',
                      label: 'Due',
                      sortable: true,
                      cellBuilder: (context, loan) => Text(loan.due),
                    ),
                    AppTableColumn<AppGalleryLoan>(
                      id: 'status',
                      label: 'Status',
                      width: 120,
                      cellBuilder: (context, loan) =>
                          AppStatusBadge(label: loan.status, tone: loan.tone),
                    ),
                  ],
                ),
              ),
            ),
            AppPagination(
              rangeLabel: 'Showing 1–4 of 128 loans',
              previousTooltip: 'Previous page',
              nextTooltip: 'Next page',
              pageCount: 12,
              currentPage: _page,
              onPageSelected: (page) => setState(() => _page = page),
              onPrevious: _page == 0 ? null : () => setState(() => _page--),
              onNext: _page == 11 ? null : () => setState(() => _page++),
            ),
          ],
        ),
      ],
    );
  }
}

/// A row in the gallery's demo table.
class AppGalleryLoan {
  const AppGalleryLoan(
    this.title,
    this.member,
    this.due,
    this.status,
    this.tone,
  );

  final String title;
  final String member;
  final String due;
  final String status;
  final AppStatusTone tone;
}

const _demoLoans = <AppGalleryLoan>[
  AppGalleryLoan(
    'A Wizard of Earthsea',
    'R. Shrestha',
    '12 Sep',
    'On loan',
    AppStatusTone.info,
  ),
  AppGalleryLoan(
    'The Dispossessed',
    'K. Tamang',
    '9 Sep',
    'Due today',
    AppStatusTone.warning,
  ),
  AppGalleryLoan(
    'The Left Hand of Darkness',
    'S. Gurung',
    '2 Sep',
    'Overdue',
    AppStatusTone.danger,
  ),
  AppGalleryLoan(
    'Always Coming Home',
    'P. Rai',
    '20 Sep',
    'On loan',
    AppStatusTone.info,
  ),
];
