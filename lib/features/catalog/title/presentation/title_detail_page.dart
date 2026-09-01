import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/title/presentation/placeholder/title_history_entry.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_copies_card.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_detail_header.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_details_card.dart';
import 'package:khulla/features/catalog/title/presentation/widgets/title_history_card.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// One work's record: what it is, the copies under it, and who has had them.
///
/// Two panes from [FormFactor.expanded] up — the copies and the history on
/// the left, where the rows need the width, and the bibliographic record on
/// the right — and one column below it. The page keeps the shell's rail
/// rather than pushing a screen over it, because a librarian moving between
/// records is still inside the catalogue.
class TitleDetailPage extends StatelessWidget {
  const TitleDetailPage({required this.titleId, super.key});

  /// The record to show, taken from the route.
  final String titleId;

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await AppDialog.confirmDestructive(
      context: context,
      title: l10n.titleDetailDeleteTitle,
      message: l10n.titleDetailDeleteBody,
      confirmLabel: l10n.titleDetailDelete,
      cancelLabel: l10n.commonCancel,
    );
    if (!context.mounted || !confirmed) return;
    showNotWiredToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final title = placeholderTitleById(titleId);
    final copies = placeholderCopiesOf(titleId);
    final twoPane = context.formFactor.isAtLeast(FormFactor.expanded);
    final description = title.description;

    final copiesCard = TitleCopiesCard(
      copies: copies,
      onAddCopy: () => showNotWiredToast(context),
      onCopyAction: (_) => showNotWiredToast(context),
    );
    const historyCard = TitleHistoryCard(
      entries: placeholderTitleHistory,
    );
    final detailsCard = TitleDetailsCard(title: title);
    final descriptionCard = description == null
        ? null
        : SectionCard(
            title: l10n.titleDetailDescription,
            icon: Icons.notes_rounded,
            child: Text(
              description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          );

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
                  title: l10n.titlesHeading,
                  onBackPressed: () => context.go(Routes.catalogTitles),
                ),
                SizedBox(height: spacing.md),
                TitleDetailHeader(
                  title: title,
                  onEdit: () => context.go(Routes.catalogTitleEdit(titleId)),
                  menuActions: [
                    AppMenuAction(
                      label: l10n.titleDetailAddCopy,
                      icon: Icons.add_circle_outline_rounded,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.titleDetailPlaceHold,
                      icon: Icons.bookmark_add_outlined,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.titlesPrintLabels,
                      icon: Icons.print_outlined,
                      onSelected: () => showNotWiredToast(context),
                    ),
                    AppMenuAction(
                      label: l10n.titleDetailDelete,
                      icon: Icons.delete_outline_rounded,
                      isDestructive: true,
                      onSelected: () => unawaited(_confirmDelete(context)),
                    ),
                  ],
                ),
                SizedBox(height: spacing.md),
                if (twoPane)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            copiesCard,
                            SizedBox(height: spacing.md),
                            historyCard,
                          ],
                        ),
                      ),
                      SizedBox(width: spacing.md),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            detailsCard,
                            if (descriptionCard != null) ...[
                              SizedBox(height: spacing.md),
                              descriptionCard,
                            ],
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  detailsCard,
                  if (descriptionCard != null) ...[
                    SizedBox(height: spacing.md),
                    descriptionCard,
                  ],
                  SizedBox(height: spacing.md),
                  copiesCard,
                  SizedBox(height: spacing.md),
                  historyCard,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
