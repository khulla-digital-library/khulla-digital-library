import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/features/opac/presentation/widgets/opac_result_card.dart';
import 'package:khulla/features/opac/presentation/widgets/opac_search_panel.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The public catalogue: what a reader sees at the reading-room machine.
///
/// It is the same data as the staff catalogue with the staff parts taken
/// away, which is the point — a separate reader-facing index is a second
/// thing to keep in step, and an out-of-date public catalogue is worse than
/// none. What differs is the *shape*: cards rather than a table, availability
/// rather than accession numbers, and one action a reader can actually take.
class OpacPage extends StatefulWidget {
  const OpacPage({super.key});

  @override
  State<OpacPage> createState() => _OpacPageState();
}

class _OpacPageState extends State<OpacPage> with DisposeBag {
  late final TextEditingController _searchController = textController();

  String _query = '';
  bool _availableOnly = false;
  String? _subject;

  List<String> get _subjects {
    final subjects = <String>{};
    for (final title in placeholderTitles) {
      subjects.addAll(title.subjects);
    }
    return subjects.take(6).toList()..sort();
  }

  List<CatalogTitle> get _matches {
    final needle = _query.trim().toLowerCase();
    return [
      for (final title in placeholderTitles)
        if ((needle.isEmpty ||
                title.title.toLowerCase().contains(needle) ||
                title.author.toLowerCase().contains(needle) ||
                title.isbn.contains(needle) ||
                title.subjects.any(
                  (subject) => subject.toLowerCase().contains(needle),
                )) &&
            (!_availableOnly || title.available > 0) &&
            (_subject == null || title.subjects.contains(_subject)))
          title,
    ];
  }

  bool get _isSearching =>
      _query.trim().isNotEmpty || _availableOnly || _subject != null;

  void _clear() => setState(() {
    _query = '';
    _availableOnly = false;
    _subject = null;
    _searchController.clear();
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final matches = _matches;
    final featured = placeholderTitles.take(6).toList();
    final showing = _isSearching ? matches : featured;

    return AppPageBody(
      wide: true,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.md,
            ),
            sliver: SliverList.list(
              children: [
                OpacSearchPanel(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  availableOnly: _availableOnly,
                  onAvailableOnlyChanged: (selected) =>
                      setState(() => _availableOnly = selected),
                  subjects: _subjects,
                  selectedSubject: _subject,
                  onSubjectSelected: (subject) =>
                      setState(() => _subject = subject),
                ),
                SizedBox(height: spacing.lg),
                AppSectionHeader(
                  title: _isSearching
                      ? l10n.opacResultsTitle
                      : l10n.opacFeaturedTitle,
                  subtitle: _isSearching
                      ? l10n.opacResultsSubtitle('${matches.length}')
                      : l10n.opacFeaturedSubtitle,
                  trailing: _isSearching
                      ? AppTextButton(
                          onPressed: _clear,
                          child: Text(l10n.commonClearFilters),
                        )
                      : null,
                ),
              ],
            ),
          ),
          if (showing.isEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.page,
                vertical: spacing.xlg,
              ),
              sliver: SliverToBoxAdapter(
                child: AppEmptyView(
                  icon: Icons.search_off_rounded,
                  title: l10n.opacEmptyTitle,
                  message: l10n.opacEmptyBody,
                  actionLabel: l10n.commonClearFilters,
                  onAction: _clear,
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: spacing.page),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisSpacing: spacing.md,
                  crossAxisSpacing: spacing.md,
                  mainAxisExtent: 188,
                ),
                itemCount: showing.length,
                itemBuilder: (context, index) {
                  final title = showing[index];
                  return OpacResultCard(
                    title: title,
                    onDetails: () => context.go(Routes.catalogTitle(title.id)),
                    onHold: () => showNotWiredToast(context),
                  );
                },
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              spacing.page,
              spacing.lg,
              spacing.page,
              spacing.xlg,
            ),
            sliver: SliverToBoxAdapter(
              child: AppCard(
                tone: AppStatusTone.info,
                child: Row(
                  children: [
                    Icon(
                      Icons.desktop_windows_outlined,
                      color: context.appColors.info,
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.opacKioskTitle,
                            style: context.textTheme.titleSmall?.copyWith(
                              color: context.appColors.textHigh,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: spacing.xxs),
                          Text(
                            l10n.opacKioskBody,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.appColors.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: spacing.sm),
                    AppButton(
                      variant: AppButtonVariant.outline,
                      onPressed: () => showNotWiredToast(context),
                      child: Text(l10n.opacKioskAction),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
