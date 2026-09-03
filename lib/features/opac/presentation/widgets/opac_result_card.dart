import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One title as a reader sees it.
///
/// The reader's card is not the librarian's row: it leads with the work and
/// its availability, and it carries no shelf-management detail — no
/// accession number, no acquisition cost, no condition. What it does carry
/// is the one thing a reader can act on, which is placing a hold when every
/// copy is out.
class OpacResultCard extends StatelessWidget {
  const OpacResultCard({
    required this.title,
    required this.onDetails,
    required this.onHold,
    super.key,
  });

  /// The work being shown.
  final CatalogTitle title;

  /// Opens the full record.
  final VoidCallback onDetails;

  /// Places a hold on the work.
  final VoidCallback onHold;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final onShelf = title.available > 0;

    return AppCard(
      onTap: onDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.brandSoft,
                  borderRadius: BorderRadius.circular(
                    context.appRadius.container,
                  ),
                  border: Border.all(color: colors.hairline),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  title.format.icon,
                  size: spacing.lg,
                  color: context.colorScheme.primary,
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleSmall?.copyWith(
                        color: colors.textHigh,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: spacing.xxs),
                    Text(
                      title.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    AppStatusBadge(
                      dense: true,
                      tone: onShelf
                          ? AppStatusTone.success
                          : AppStatusTone.warning,
                      label: onShelf
                          ? l10n.opacCopiesAvailable(
                              '${title.available}',
                              '${title.copies}',
                            )
                          : l10n.opacNoCopies,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${title.format.label(l10n)} · ${title.year} · ${title.shelf}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ),
              AppButton(
                variant: AppButtonVariant.outline,
                onPressed: onShelf ? onDetails : onHold,
                child: Text(
                  onShelf ? l10n.opacViewDetails : l10n.opacPlaceHold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
