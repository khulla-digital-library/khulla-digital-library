import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/components/section_card.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The bibliographic record, as label/value pairs.
class TitleDetailsCard extends StatelessWidget {
  const TitleDetailsCard({required this.title, super.key});

  final catalog.Title title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final notSet = l10n.commonNotSet;
    final pages = title.pages;

    return SectionCard(
      title: l10n.titleDetailOverview,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, row) in <(String, String)>[
            (l10n.fieldIsbn, title.isbn ?? notSet),
            (l10n.fieldPublisher, title.publisher ?? notSet),
            (l10n.fieldPublishedYear, title.year.isEmpty ? notSet : title.year),
            (l10n.fieldEdition, title.edition ?? notSet),
            (l10n.fieldLanguage, title.language),
            (
              l10n.fieldFormat,
              title.formatCode.formatLabel(l10n),
            ),
            (l10n.fieldPages, pages == null ? notSet : '$pages'),
            (
              l10n.fieldSubjects,
              title.subjects.isEmpty ? notSet : title.subjects.join(', '),
            ),
            (l10n.fieldShelf, title.shelf ?? notSet),
            (l10n.fieldReplacementCost, title.replacementCost.display()),
            (l10n.fieldAddedOn, title.addedOn),
          ].indexed) ...[
            if (index > 0) SizedBox(height: spacing.sm),
            AppDetailRow(label: row.$1, child: Text(row.$2)),
          ],
        ],
      ),
    );
  }
}
