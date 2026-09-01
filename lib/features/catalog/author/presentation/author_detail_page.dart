import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One author's record and everything the catalogue credits to them.
class AuthorDetailPage extends StatelessWidget {
  const AuthorDetailPage({required this.authorId, super.key});

  /// The record to show, taken from the route.
  final String authorId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final scheme = context.colorScheme;
    final author = placeholderAuthorById(authorId);
    final biography = author.biography;
    final titles = [
      for (final title in placeholderTitles)
        if (title.author == author.name) title,
    ];

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
                AppPageHeader(
                  title: l10n.authorsHeading,
                  onBackPressed: () => context.go(Routes.catalogAuthors),
                ),
                SizedBox(height: spacing.md),
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(initials: author.initials, size: 56),
                      SizedBox(width: spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              author.name,
                              style: context.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.5,
                                color: context.appColors.textHigh,
                              ),
                            ),
                            SizedBox(height: spacing.xs),
                            Wrap(
                              spacing: spacing.xs,
                              runSpacing: spacing.xs,
                              children: [
                                if (author.lifespan case final lifespan?)
                                  AppStatusBadge(
                                    label: lifespan,
                                    icon: Icons.schedule_rounded,
                                  ),
                                if (author.nationality case final nationality?)
                                  AppStatusBadge(
                                    label: nationality,
                                    icon: Icons.public_rounded,
                                  ),
                                AppStatusBadge(
                                  label: l10n.authorsSubtitle(
                                    '${author.titleCount}',
                                  ),
                                  icon: Icons.menu_book_rounded,
                                  tone: AppStatusTone.brand,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      AppButton(
                        size: AppButtonSize.medium,
                        variant: AppButtonVariant.outline,
                        onPressed: () => showNotWiredToast(context),
                        child: Text(l10n.authorDetailEdit),
                      ),
                    ],
                  ),
                ),
                if (biography != null) ...[
                  SizedBox(height: spacing.md),
                  SectionCard(
                    title: l10n.authorDetailBiography,
                    icon: Icons.person_outline_rounded,
                    child: Text(
                      biography,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: spacing.md),
                SectionCard(
                  title: l10n.authorDetailTitlesTitle,
                  subtitle: l10n.authorDetailTitlesSubtitle,
                  icon: Icons.menu_book_rounded,
                  child: titles.isEmpty
                      ? AppEmptyView(
                          variant: AppFeedbackVariant.inline,
                          title: l10n.titlesEmptyTitle,
                          message: l10n.titlesEmptyBody,
                        )
                      : AppTable<CatalogTitle>(
                          items: titles,
                          onRowTap: (title) =>
                              context.go(Routes.catalogTitle(title.id)),
                          columns: [
                            AppTableColumn<CatalogTitle>(
                              id: 'title',
                              label: l10n.titlesColumnTitle,
                              flex: 4,
                              cellBuilder: (context, title) =>
                                  Text(title.title),
                            ),
                            AppTableColumn<CatalogTitle>(
                              id: 'year',
                              label: l10n.titlesColumnYear,
                              width: 90,
                              showFrom: FormFactor.medium,
                              cellBuilder: (context, title) => Text(title.year),
                            ),
                            AppTableColumn<CatalogTitle>(
                              id: 'shelf',
                              label: l10n.titlesColumnShelf,
                              flex: 2,
                              showFrom: FormFactor.expanded,
                              cellBuilder: (context, title) =>
                                  Text(title.shelf),
                            ),
                            AppTableColumn<CatalogTitle>(
                              id: 'available',
                              label: l10n.titlesColumnAvailable,
                              width: 120,
                              alignment: Alignment.centerRight,
                              cellBuilder: (context, title) => Text(
                                l10n.titlesCopiesOf(
                                  '${title.available}',
                                  '${title.copies}',
                                ),
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
