import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/record_header.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A title's identity block: what the work is, how it stands, and what the
/// librarian can do with it.
///
/// Secondary actions sit in the open rather than behind an overflow menu. Delete
/// uses the destructive button variant so it reads clearly without competing
/// with edit for emphasis; the confirm dialog still carries the full sentence.
/// The status row is two badges at most: whether a copy can be taken off the shelf,
/// and whether the title is reference only. Format and copy count moved into the
/// fact line — a librarian reads them, but nobody has to act on them.
class TitleDetailHeader extends StatelessWidget {
  const TitleDetailHeader({
    required this.title,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final catalog.Title title;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isAvailable = title.availableCount > 0;

    return RecordHeader(
      title: title.title,
      subtitle: Text(
        title.author,
        style: context.textTheme.bodyMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      facts: [
        title.formatCode.formatLabel(l10n),
        l10n.titlesCopiesOf(
          '${title.availableCount}',
          '${title.copyCount}',
        ),
      ],
      badges: [
        AppStatusBadge(
          showDot: false,
          label: isAvailable ? l10n.statusAvailable : l10n.statusOnLoan,
          tone: isAvailable ? AppStatusTone.success : AppStatusTone.brand,
        ),
        if (!title.lendable)
          AppStatusBadge(
            showDot: false,
            label: l10n.titlesReferenceOnly,
            tone: AppStatusTone.warning,
          ),
      ],
      actions: [
        Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AppButton(
              variant: AppButtonVariant.destructive,
              size: AppButtonSize.medium,
              icon: AppIcons.delete,
              onPressed: onDelete,
              child: Text(l10n.titleDetailDelete),
            ),
            AppButton(
              size: AppButtonSize.medium,
              onPressed: onEdit,
              child: Text(l10n.titleDetailEdit(title.title)),
            ),
          ],
        ),
      ],
    );
  }
}
