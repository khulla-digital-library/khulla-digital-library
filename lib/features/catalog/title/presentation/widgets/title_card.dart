import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One title as a card, for the window classes where a five-column table
/// would be five columns of ellipses.
///
/// It is handed to `AppSliverTable.compactBuilder`, which gives every card the
/// same extent, so the card is laid out to a fixed height and must not grow
/// past it — two lines of title, one line of author, one row of standing.
class TitleCard extends StatelessWidget {
  const TitleCard({required this.title, required this.onTap, super.key});

  final CatalogTitle title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final isAvailable = title.available > 0;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              title.format.icon,
              size: spacing.md + 4,
              color: scheme.onSurfaceVariant,
            ),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    title.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: spacing.xs),
                  Row(
                    children: [
                      AppStatusBadge(
                        dense: true,
                        label: isAvailable
                            ? l10n.statusAvailable
                            : l10n.statusOnLoan,
                        tone: isAvailable
                            ? AppStatusTone.success
                            : AppStatusTone.brand,
                      ),
                      SizedBox(width: spacing.xs),
                      Flexible(
                        child: Text(
                          l10n.titlesCopiesOf(
                            '${title.available}',
                            '${title.copies}',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
