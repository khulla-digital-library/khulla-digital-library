import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_author.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One author as a card, for a compact window.
class AuthorCard extends StatelessWidget {
  const AuthorCard({
    required this.author,
    required this.titlesLabel,
    required this.onTap,
    super.key,
  });

  final CatalogAuthor author;

  /// How many titles they are credited on, already localized.
  final String titlesLabel;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final lifespan = author.lifespan;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            AppAvatar(initials: author.initials),
            SizedBox(width: spacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    author.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: scheme.onSurface,
                    ),
                  ),
                  SizedBox(height: spacing.xxs),
                  Text(
                    lifespan == null ? titlesLabel : '$lifespan · $titlesLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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
