import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/catalog/shared/domain/catalog_format.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_placeholder.dart';
import 'package:khulla/features/catalog/shared/presentation/placeholder/catalog_title.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The title editor, used for both a new work and an existing one.
///
/// A form, so it keeps the reading content cap rather than the wide one — a
/// field row stretched across a 2560px monitor is a bug. Fields that are
/// genuinely independent pair up through [AppFormRow], which stacks them
/// again when the slot narrows.
///
/// Nothing is validated yet: validation is `formz` input state on a cubit,
/// and this build has no cubit behind it. The error slots the fields already
/// carry are where those messages will land.
class TitleFormPage extends StatefulWidget {
  const TitleFormPage({this.titleId, super.key});

  /// The record being edited, or null for a new work.
  final String? titleId;

  @override
  State<TitleFormPage> createState() => _TitleFormPageState();
}

class _TitleFormPageState extends State<TitleFormPage> with DisposeBag {
  late final TextEditingController _title = textController(_existing?.title);
  late final TextEditingController _subtitle = textController(
    _existing?.subtitle,
  );
  late final TextEditingController _author = textController(_existing?.author);
  late final TextEditingController _isbn = textController(_existing?.isbn);
  late final TextEditingController _publisher = textController(
    _existing?.publisher,
  );
  late final TextEditingController _year = textController(_existing?.year);
  late final TextEditingController _edition = textController(
    _existing?.edition,
  );
  late final TextEditingController _language = textController(
    _existing?.language,
  );
  late final TextEditingController _pages = textController(
    _existing?.pages?.toString(),
  );
  late final TextEditingController _subjects = textController(
    _existing?.subjects.join(', '),
  );
  late final TextEditingController _shelf = textController(_existing?.shelf);
  late final TextEditingController _description = textController(
    _existing?.description,
  );
  late final TextEditingController _replacementCost = textController(
    _existing?.replacementCost.editable,
  );
  late final TextEditingController _initialCopies = textController(
    _isEditing ? null : '1',
  );

  late CatalogFormat _format = _existing?.format ?? CatalogFormat.book;
  late bool _lendable = _existing?.lendable ?? true;

  bool get _isEditing => widget.titleId != null;

  /// The record being edited, or null while creating one.
  ///
  /// Read once through the placeholder lookup; a cubit reads it once in
  /// `loadTitle(id)` and hands the same shape to these controllers.
  late final CatalogTitle? _existing = _isEditing
      ? placeholderTitleById(widget.titleId!)
      : null;

  void _close() => context.go(
    _isEditing ? Routes.catalogTitle(widget.titleId!) : Routes.catalogTitles,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AppPageBody(
      wide: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          spacing.page,
          spacing.lg,
          spacing.page,
          spacing.xlg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPageHeader(
              title: _isEditing
                  ? l10n.titleFormEditHeading
                  : l10n.titleFormNewHeading,
              onBackPressed: _close,
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.titleFormBibliographic,
              description: l10n.titleFormBibliographicDescription,
              children: [
                AppTextField(
                  label: l10n.fieldTitle,
                  required: true,
                  controller: _title,
                  hintText: l10n.fieldTitle,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldSubtitle,
                  controller: _subtitle,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {},
                ),
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldAuthor,
                      required: true,
                      controller: _author,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldIsbn,
                      controller: _isbn,
                      keyboardType: TextInputType.text,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldPublisher,
                      controller: _publisher,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldPublishedYear,
                      controller: _year,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppFormRow(
                  children: [
                    AppDropdownField<CatalogFormat>(
                      label: l10n.fieldFormat,
                      value: _format,
                      items: CatalogFormat.values,
                      itemLabel: (format) => format.label(l10n),
                      itemIcon: (format) => format.icon,
                      onChanged: (format) => setState(
                        () => _format = format ?? _format,
                      ),
                    ),
                    AppTextField(
                      label: l10n.fieldLanguage,
                      controller: _language,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldEdition,
                      controller: _edition,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldPages,
                      controller: _pages,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppTextField(
                  label: l10n.fieldSubjects,
                  controller: _subjects,
                  hintText: l10n.fieldSubjects,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldDescription,
                  controller: _description,
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) {},
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.titleFormShelving,
              description: l10n.titleFormShelvingDescription,
              children: [
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldShelf,
                      controller: _shelf,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldReplacementCost,
                      controller: _replacementCost,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppSwitchField(
                  value: _lendable,
                  label: l10n.titleFormLendable,
                  description: l10n.titleFormLendableDescription,
                  onChanged: (value) => setState(() => _lendable = value),
                ),
              ],
            ),
            if (!_isEditing) ...[
              SizedBox(height: spacing.lg),
              AppFormSection(
                title: l10n.titleFormCopies,
                description: l10n.titleFormCopiesDescription,
                children: [
                  AppTextField(
                    label: l10n.titleFormInitialCopies,
                    controller: _initialCopies,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
            SizedBox(height: spacing.xlg),
            Row(
              children: [
                AppButton(
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  onPressed: _close,
                  child: Text(l10n.commonCancel),
                ),
                const Spacer(),
                AppButton(
                  size: AppButtonSize.medium,
                  onPressed: () => showNotWiredToast(context),
                  child: Text(l10n.titleFormSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
