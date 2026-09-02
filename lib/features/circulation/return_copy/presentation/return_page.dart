import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/domain/copy_condition.dart';
import 'package:khulla/features/circulation/return_copy/presentation/widgets/return_basket.dart';
import 'package:khulla/features/circulation/return_copy/presentation/widgets/return_summary_card.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/circulation_placeholder.dart';
import 'package:khulla/features/circulation/shared/presentation/placeholder/loan_record.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/collection_header.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The returns desk: scan, price, confirm.
///
/// A return is several writes in one gesture — the copy goes back on the
/// shelf, the loan closes, a fine may be raised, and a hold behind the title
/// may become ready. That is why the confirm button is one button at the
/// bottom of a summary, rather than an action per row.
class ReturnPage extends StatefulWidget {
  const ReturnPage({super.key});

  @override
  State<ReturnPage> createState() => _ReturnPageState();
}

class _ReturnPageState extends State<ReturnPage> with DisposeBag {
  late final TextEditingController _scan = textController();

  final List<LoanRecord> _returning = [];
  bool _waiveFines = false;
  CopyCondition _condition = CopyCondition.good;

  /// Adds the next outstanding loan, whatever was typed.
  ///
  /// A real scan looks the barcode up among open loans and says so when the
  /// copy was not out in the first place.
  void _addScanned(String _) {
    final next = placeholderLoans.firstWhere(
      (loan) => !_returning.contains(loan),
      orElse: () => placeholderLoans.first,
    );
    setState(() {
      if (!_returning.contains(next)) _returning.add(next);
      _scan.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final twoPane = context.formFactor.isAtLeast(FormFactor.expanded);
    final lateCount = _returning.where((loan) => loan.daysLate > 0).length;
    final finesDue = _waiveFines
        ? Money.zero
        : Money.sum([for (final loan in _returning) loan.accruedFine]);

    final basket = ReturnBasket(
      loans: _returning,
      scanController: _scan,
      onScanSubmitted: _addScanned,
      onRemove: (loan) => setState(() => _returning.remove(loan)),
    );

    final summary = ReturnSummaryCard(
      copyCount: _returning.length,
      lateCount: lateCount,
      finesDue: finesDue,
      waiveFines: _waiveFines,
      onWaiveChanged: (value) => setState(() => _waiveFines = value),
      condition: _condition,
      onConditionChanged: (value) => setState(() => _condition = value),
      onConfirm: _returning.isEmpty ? null : () => showNotWiredToast(context),
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
                  title: l10n.returnsHeading,
                  subtitle: l10n.returnsSubtitle,
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
                      Expanded(flex: 3, child: basket),
                      SizedBox(width: spacing.md),
                      Expanded(flex: 2, child: summary),
                    ],
                  )
                else ...[
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
