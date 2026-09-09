import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_copy_row.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every item of this work the library holds.
///
/// A short row list rather than a table: a title has a handful of copies, so
/// column headers and a "With" column of dashes bought more chrome than
/// clarity. Add-copy lives in the page header; per-copy maintenance routes
/// through the three action callbacks on each [TitleCopyRow].
class TitleCopiesCard extends StatelessWidget {
  const TitleCopiesCard({
    required this.copies,
    required this.onMarkLost,
    required this.onMarkDamaged,
    required this.onWithdraw,
    super.key,
  });

  final List<Copy> copies;
  final void Function(Copy copy) onMarkLost;
  final void Function(Copy copy) onMarkDamaged;
  final void Function(Copy copy) onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.appColors;

    return SectionCard(
      title: l10n.titleDetailCopiesTitle,
      subtitle: l10n.titleDetailCopiesSubtitle,
      child: copies.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.titleDetailCopiesEmptyTitle,
              message: l10n.titleDetailCopiesEmptyBody,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, copy) in copies.indexed) ...[
                  if (index > 0) Divider(height: 1, color: colors.hairline),
                  TitleCopyRow(
                    copy: copy,
                    onMarkLost: () => onMarkLost(copy),
                    onMarkDamaged: () => onMarkDamaged(copy),
                    onWithdraw: () => onWithdraw(copy),
                  ),
                ],
              ],
            ),
    );
  }
}
