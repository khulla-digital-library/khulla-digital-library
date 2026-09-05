import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_status_badge.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Every item of this work the library holds.
///
/// [AppTable] rather than the sliver form: a title has a handful of copies,
/// the count is known before the card is built, and the table lives inside a
/// card rather than owning the page's scroll view. Add-copy is wired through
/// [onAddCopy]; per-copy maintenance routes through the three action callbacks.
class TitleCopiesCard extends StatelessWidget {
  const TitleCopiesCard({
    required this.copies,
    required this.onAddCopy,
    required this.onMarkLost,
    required this.onMarkDamaged,
    required this.onWithdraw,
    super.key,
  });

  final List<Copy> copies;
  final VoidCallback onAddCopy;
  final void Function(Copy copy) onMarkLost;
  final void Function(Copy copy) onMarkDamaged;
  final void Function(Copy copy) onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.titleDetailCopiesTitle,
      subtitle: l10n.titleDetailCopiesSubtitle,
      trailing: AppButton(
        variant: AppButtonVariant.outline,
        icon: AppIcons.add,
        onPressed: onAddCopy,
        child: Text(l10n.titleDetailAddCopy),
      ),
      child: copies.isEmpty
          ? AppEmptyView(
              variant: AppFeedbackVariant.inline,
              title: l10n.titleDetailCopiesEmptyTitle,
              message: l10n.titleDetailCopiesEmptyBody,
            )
          : AppTable<Copy>(
              items: copies,
              columns: [
                AppTableColumn<Copy>(
                  id: 'barcode',
                  label: l10n.copiesColumnBarcode,
                  flex: 2,
                  cellBuilder: (context, copy) => Text(copy.barcode),
                ),
                AppTableColumn<Copy>(
                  id: 'shelf',
                  label: l10n.copiesColumnShelf,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, copy) => Text(copy.shelf),
                ),
                AppTableColumn<Copy>(
                  id: 'condition',
                  label: l10n.copiesColumnCondition,
                  flex: 2,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, copy) => Text(
                    copy.condition.label(l10n),
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<Copy>(
                  id: 'borrower',
                  label: l10n.copiesColumnBorrower,
                  flex: 2,
                  showFrom: FormFactor.large,
                  cellBuilder: (context, copy) => Text(
                    copy.borrower ?? l10n.commonNotSet,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<Copy>(
                  id: 'due',
                  label: l10n.copiesColumnDue,
                  flex: 2,
                  showFrom: FormFactor.large,
                  cellBuilder: (context, copy) => Text(
                    copy.dueDate ?? l10n.commonNotSet,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<Copy>(
                  id: 'status',
                  label: l10n.commonStatus,
                  width: 130,
                  cellBuilder: (context, copy) =>
                      CopyStatusBadge(status: copy.status),
                ),
                AppTableColumn<Copy>(
                  id: 'actions',
                  label: l10n.commonActions,
                  width: 56,
                  alignment: Alignment.centerRight,
                  cellBuilder: (context, copy) => AppMenuButton(
                    tooltip: l10n.commonMoreActions,
                    actions: [
                      AppMenuAction(
                        label: l10n.copiesMarkLost,
                        icon: AppIcons.help,
                        onSelected: () => onMarkLost(copy),
                      ),
                      AppMenuAction(
                        label: l10n.copiesMarkDamaged,
                        icon: AppIcons.damage,
                        onSelected: () => onMarkDamaged(copy),
                      ),
                      AppMenuAction(
                        label: l10n.copiesWithdraw,
                        icon: AppIcons.delete,
                        isDestructive: true,
                        onSelected: () => onWithdraw(copy),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
