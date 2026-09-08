import 'package:khulla/features/catalog/copy/domain/models/copy.dart';
import 'package:khulla/features/catalog/copy/presentation/widgets/copy_status_badge.dart';
import 'package:khulla/features/catalog/shared/domain/copy_status.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One copy on a title's detail screen — barcode, standing, and who has it
/// when it is out.
///
/// A table with a "With" column full of dashes was worse than a short row
/// list: three copies do not need column headers, and the borrower line only
/// appears when the copy is actually on loan.
class TitleCopyRow extends StatelessWidget {
  const TitleCopyRow({
    required this.copy,
    required this.onMarkLost,
    required this.onMarkDamaged,
    required this.onWithdraw,
    super.key,
  });

  final Copy copy;
  final VoidCallback onMarkLost;
  final VoidCallback onMarkDamaged;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final checkedOut =
        copy.status == CopyStatus.onLoan && copy.borrower != null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  copy.barcode,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurface,
                  ),
                ),
                if (checkedOut) ...[
                  SizedBox(height: spacing.xxs),
                  Text(
                    l10n.titleDetailCopyCheckedOut(
                      copy.borrower!,
                      copy.dueDate ?? l10n.commonNotSet,
                    ),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          CopyStatusBadge(status: copy.status, showDot: false),
          SizedBox(width: spacing.xs),
          AppMenuButton(
            tooltip: l10n.commonMoreActions,
            actions: [
              AppMenuAction(
                label: l10n.copiesMarkLost,
                icon: AppIcons.help,
                onSelected: onMarkLost,
              ),
              AppMenuAction(
                label: l10n.copiesMarkDamaged,
                icon: AppIcons.damage,
                onSelected: onMarkDamaged,
              ),
              AppMenuAction(
                label: l10n.copiesWithdraw,
                icon: AppIcons.delete,
                isDestructive: true,
                onSelected: onWithdraw,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
