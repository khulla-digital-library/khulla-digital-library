import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/record_header.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// A title's identity block: what the work is, how it stands, and the one
/// thing the page is for.
///
/// Secondary actions sit behind [AppMenuButton] rather than becoming a row of
/// equal buttons, and the destructive one is inside that menu — never beside
/// the primary action.
/// A title's identity at the top of its detail screen.
///
/// The status row is two badges at most: whether a copy can be taken off the
/// shelf, and whether the title is reference only. The format and the copy
/// count moved into the fact line — a librarian reads them, but nobody has to
/// act on them, and pills spend attention that the availability badge needs.
class TitleDetailHeader extends StatelessWidget {
  const TitleDetailHeader({
    required this.title,
    required this.onEdit,
    required this.menuActions,
    super.key,
  });

  final CatalogTitle title;
  final VoidCallback onEdit;
  final List<AppMenuAction> menuActions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isAvailable = title.available > 0;
    final subtitle = title.subtitle;

    return RecordHeader(
      title: title.title,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            Text(
              subtitle,
              style: context.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: spacing.xxs),
          ],
          Text(
            title.author,
            style: context.textTheme.bodyMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      facts: [
        title.format.label(l10n),
        l10n.titlesCopiesOf('${title.available}', '${title.copies}'),
      ],
      badges: [
        AppStatusBadge(
          label: isAvailable ? l10n.statusAvailable : l10n.statusOnLoan,
          tone: isAvailable ? AppStatusTone.success : AppStatusTone.brand,
        ),
        if (!title.lendable)
          AppStatusBadge(
            label: l10n.titlesReferenceOnly,
            tone: AppStatusTone.warning,
          ),
      ],
      actions: [
        AppMenuButton(actions: menuActions, tooltip: l10n.commonMoreActions),
        SizedBox(width: spacing.xs),
        AppButton(
          size: AppButtonSize.medium,
          onPressed: onEdit,
          child: Text(l10n.titleDetailEdit),
        ),
      ],
    );
  }
}
