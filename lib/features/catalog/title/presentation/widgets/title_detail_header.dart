import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/record_header.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A title's identity block: what the work is, how it stands, and what the
/// librarian can do with it.
///
/// Edit is the one action in the open — it is the thing a librarian reaches
/// for most. Delete sits behind the overflow menu instead of beside Edit as a
/// second loud button: a destructive control never shares an edge with the
/// primary one, so a rushed click can't land on the wrong thing. The confirm
/// dialog still carries the full sentence. The status row is two badges at
/// most: whether a copy can be taken off the shelf, and whether the title is
/// reference only. Format, shelf and copy count moved into the fact line — a
/// librarian reads them, but nobody has to act on them.
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
        if (title.shelf case final shelf?) l10n.titleDetailShelfFact(shelf),
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
        AppMenuButton(
          tooltip: l10n.commonMoreActions,
          actions: [
            AppMenuAction(
              label: l10n.titleDetailDelete,
              icon: AppIcons.delete,
              isDestructive: true,
              onSelected: onDelete,
            ),
          ],
        ),
        SizedBox(width: spacing.xs),
        AppButton(
          size: AppButtonSize.medium,
          onPressed: onEdit,
          child: Text(l10n.titleDetailEdit(title.title)),
        ),
      ],
    );
  }
}
