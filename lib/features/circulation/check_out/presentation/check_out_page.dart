import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_copy.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/circulation/check_out/presentation/widgets/check_out_basket.dart';
import 'package:khulla/features/circulation/check_out/presentation/widgets/check_out_member_card.dart';
import 'package:khulla/features/circulation/check_out/presentation/widgets/check_out_summary_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The checkout desk: a member, a basket of copies, and one button.
///
/// Two panes from [FormFactor.expanded] up, with the summary on the right
/// where it stays visible as copies are scanned; one column below that. The
/// scan field never leaves the top of the basket, because the barcode reader
/// is the only input a busy desk uses.
///
/// The flow is local state today. When `CheckOutCubit` lands it owns the
/// chosen member and the basket, `checkOutCopy()` names the outcome rather
/// than the gesture, and the failure of that write answers as a toast — not
/// as a screen state.
class CheckOutPage extends StatefulWidget {
  const CheckOutPage({super.key});

  @override
  State<CheckOutPage> createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> with DisposeBag {
  /// Stand-in for the member a lookup would return.
  static const String _memberName = 'Anita Rai';
  static const String _memberCard = 'KH-M-0104';
  static const String _memberInitials = 'AR';
  static const int _loanPeriodDays = 14;
  static const int _borrowingLimit = 5;
  static const String _dueDate = '15 Sep 2026';

  late final TextEditingController _scan = textController();

  final List<CatalogCopy> _basket = [];
  bool _hasMember = false;

  /// Adds the next placeholder copy, whatever was typed.
  ///
  /// A real scan resolves the barcode through the copies data source and
  /// refuses one that is already out; here the point is the shape of the
  /// interaction — submit, clear, keep focus.
  void _addScanned(String _) {
    final next = placeholderCopies.firstWhere(
      (copy) => !_basket.contains(copy),
      orElse: () => placeholderCopies.first,
    );
    setState(() {
      if (!_basket.contains(next)) _basket.add(next);
      _scan.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final twoPane = context.formFactor.isAtLeast(FormFactor.expanded);
    final outstanding = _hasMember ? Money.major(15) : Money.zero;

    final memberCard = CheckOutMemberCard(
      memberName: _hasMember ? _memberName : null,
      memberCard: _hasMember ? _memberCard : null,
      memberCategory: _hasMember ? l10n.membersCategoryPublic : null,
      initials: _hasMember ? _memberInitials : null,
      outstandingFines: outstanding,
      onSearchChanged: (value) =>
          setState(() => _hasMember = value.trim().isNotEmpty),
      onChangeMember: () => setState(() => _hasMember = false),
    );

    final basket = CheckOutBasket(
      copies: _basket,
      scanController: _scan,
      onScanSubmitted: _addScanned,
      onRemove: (copy) => setState(() => _basket.remove(copy)),
    );

    final summary = CheckOutSummaryCard(
      copyCount: _basket.length,
      loanPeriodDays: _loanPeriodDays,
      dueDate: _dueDate,
      borrowingLimit: _borrowingLimit,
      outstandingFines: outstanding,
      onConfirm: _hasMember && _basket.isNotEmpty
          ? () => showNotWiredToast(context)
          : null,
    );

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
                CollectionHeader(
                  title: l10n.checkOutHeading,
                  subtitle: l10n.checkOutSubtitle,
                  leading: AppPageHeader(
                    title: l10n.circulationHeading,
                    onBackPressed: () => context.go(Routes.circulation),
                  ),
                ),
                SizedBox(height: spacing.lg),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            memberCard,
                            SizedBox(height: spacing.md),
                            basket,
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(flex: 2, child: summary),
                    ],
                  )
                else ...[
                  memberCard,
                  SizedBox(height: spacing.md),
                  basket,
                  SizedBox(height: spacing.md),
                  summary,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
