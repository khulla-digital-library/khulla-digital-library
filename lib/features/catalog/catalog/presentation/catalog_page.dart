import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/catalog/presentation/cubit/catalog_overview_cubit.dart';
import 'package:khulla/features/catalog/catalog/presentation/cubit/catalog_overview_state.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The catalogue's landing page: the size of the collection, the three lists
/// behind it, and what was accessioned most recently.
///
/// It owns no resource of its own — titles, copies and authors each have their
/// own sub-feature — so this page is a board, not a list, and takes the wide
/// content cap like the dashboard does. [CatalogOverviewCubit] supplies the
/// counts and recent titles; the authors stat tile still links ahead of that
/// sub-feature being wired.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return BlocBuilder<CatalogOverviewCubit, CatalogOverviewState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: context.read<CatalogOverviewCubit>().loadOverview,
          );
        }

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
                    AppStatStrip(
                      tiles: [
                        AppStatTile(
                          label: l10n.catalogStatTitles,
                          value: '${state.titleCount}',
                          icon: AppIcons.book,
                          onTap: () => context.go(Routes.catalogTitles),
                        ),
                        AppStatTile(
                          label: l10n.catalogStatCopies,
                          value: '${state.copyCount}',
                          icon: AppIcons.inventory,
                          tone: AppStatusTone.brand,
                          onTap: () => context.go(Routes.catalogCopies),
                        ),
                        AppStatTile(
                          label: l10n.catalogStatAvailable,
                          value: '${state.availableCount}',
                          icon: AppIcons.success,
                          tone: AppStatusTone.success,
                          onTap: () => context.go(Routes.catalogCopies),
                        ),
                        AppStatTile(
                          label: l10n.catalogStatAuthors,
                          value: '${state.authorCount}',
                          icon: AppIcons.person,
                          tone: AppStatusTone.info,
                          onTap: () => context.go(Routes.catalogAuthors),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.lg),
                    _RecentlyCatalogued(titles: state.recentTitles),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentlyCatalogued extends StatelessWidget {
  const _RecentlyCatalogued({required this.titles});

  final List<catalog.Title> titles;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;

    return SectionCard(
      title: l10n.catalogRecentTitle,
      subtitle: l10n.catalogRecentSubtitle,
      trailing: AppTextButton(
        onPressed: () => context.go(Routes.catalogTitles),
        child: Text(l10n.commonOpen),
      ),
      child: titles.isEmpty
          ? AppEmptyView(
              icon: AppIcons.book,
              title: l10n.catalogRecentEmptyTitle,
              message: l10n.catalogRecentEmptyBody,
            )
          : AppTable<catalog.Title>(
              items: titles,
              onRowTap: (title) => context.go(Routes.catalogTitle(title.id)),
              columns: [
                AppTableColumn<catalog.Title>(
                  id: 'title',
                  label: l10n.titlesColumnTitle,
                  flex: 3,
                  cellBuilder: (context, title) => Text(title.title),
                ),
                AppTableColumn<catalog.Title>(
                  id: 'author',
                  label: l10n.titlesColumnAuthor,
                  flex: 2,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, title) => Text(
                    title.author,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
                AppTableColumn<catalog.Title>(
                  id: 'shelf',
                  label: l10n.titlesColumnShelf,
                  showFrom: FormFactor.expanded,
                  cellBuilder: (context, title) => Text(title.shelf ?? ''),
                ),
                AppTableColumn<catalog.Title>(
                  id: 'addedOn',
                  label: l10n.fieldAddedOn,
                  alignment: Alignment.centerRight,
                  showFrom: FormFactor.medium,
                  cellBuilder: (context, title) => Text(
                    title.addedOn,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
