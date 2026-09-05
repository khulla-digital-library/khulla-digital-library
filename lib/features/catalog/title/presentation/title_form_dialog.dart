import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/catalog/shared/presentation/catalog_labels.dart';
import 'package:khulla/features/catalog/title/domain/models/title.dart'
    as catalog;
import 'package:khulla/features/catalog/title/domain/models/title_format.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title_form_cubit.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title_form_state.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The title editor, used for both a new work and an existing one.
class TitleFormDialog extends StatelessWidget {
  const TitleFormDialog({this.titleId, super.key});

  final String? titleId;

  static Future<bool?> show(BuildContext context, {String? titleId}) =>
      AppFormModal.show<bool>(
        context: context,
        builder: (_) => BlocProvider(
          create: (_) {
            final cubit = getIt<TitleFormCubit>();
            unawaited(cubit.load(titleId: titleId));
            return cubit;
          },
          child: TitleFormDialog(titleId: titleId),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = titleId != null;

    return BlocBuilder<TitleFormCubit, TitleFormState>(
      builder: (context, state) {
        if (state.isLoading) {
          return AppFormModal(
            title: isEditing
                ? l10n.titleFormEditHeading
                : l10n.titleFormNewHeading,
            width: AppDialogWidth.xxxl,
            actions: const [],
            children: const [Center(child: AppSpinner())],
          );
        }

        return _TitleFormBody(
          key: ValueKey(titleId ?? 'new'),
          titleId: titleId,
          existing: state.existing,
          formats: state.formats,
          isSaving: state.isSaving,
        );
      },
    );
  }
}

class _TitleFormBody extends StatefulWidget {
  const _TitleFormBody({
    required this.titleId,
    required this.existing,
    required this.formats,
    required this.isSaving,
    super.key,
  });

  final String? titleId;
  final catalog.Title? existing;
  final List<TitleFormat> formats;
  final bool isSaving;

  @override
  State<_TitleFormBody> createState() => _TitleFormBodyState();
}

class _TitleFormBodyState extends State<_TitleFormBody> with DisposeBag {
  late final TextEditingController _title = textController(
    widget.existing?.title,
  );
  late final TextEditingController _subtitle = textController(
    widget.existing?.subtitle,
  );
  late final TextEditingController _author = textController(
    widget.existing?.author,
  );
  late final TextEditingController _isbn = textController(
    widget.existing?.isbn,
  );
  late final TextEditingController _publisher = textController(
    widget.existing?.publisher,
  );
  late final TextEditingController _year = textController(
    widget.existing?.year,
  );
  late final TextEditingController _edition = textController(
    widget.existing?.edition,
  );
  late final TextEditingController _language = textController(
    widget.existing?.language ?? 'English',
  );
  late final TextEditingController _pages = textController(
    widget.existing?.pages?.toString(),
  );
  late final TextEditingController _subjects = textController(
    widget.existing?.subjects.join(', '),
  );
  late final TextEditingController _shelf = textController(
    widget.existing?.shelf,
  );
  late final TextEditingController _description = textController(
    widget.existing?.description,
  );
  late final TextEditingController _replacementCost = textController(
    widget.existing?.replacementCost.editable,
  );
  late final TextEditingController _initialCopies = textController(
    _isEditing ? null : '1',
  );

  late String _formatId =
      widget.existing?.formatId ??
      (widget.formats.isNotEmpty ? widget.formats.first.id : '');
  late bool _lendable = widget.existing?.lendable ?? true;

  bool get _isEditing => widget.titleId != null;

  TitleFormat? get _selectedFormat {
    for (final format in widget.formats) {
      if (format.id == _formatId) return format;
    }
    return widget.formats.isEmpty ? null : widget.formats.first;
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final author = _author.text.trim();
    if (title.isEmpty || author.isEmpty || _formatId.isEmpty) {
      AppToast.error(context, message: l10n.validationFieldRequired);
      return;
    }
    if (!_replacementCost.text.isValidMoney) {
      AppToast.error(context, message: l10n.validationFieldRequired);
      return;
    }
    final initialCopies = _isEditing
        ? 0
        : int.tryParse(_initialCopies.text) ?? 0;
    final publishedYear = int.tryParse(_year.text.trim());
    final pages = int.tryParse(_pages.text.trim());
    final subjects = _subjects.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    try {
      await context.read<TitleFormCubit>().saveTitle(
        title: title,
        author: author,
        formatId: _formatId,
        subtitle: _subtitle.text.trim().isEmpty ? null : _subtitle.text.trim(),
        isbn: _isbn.text.trim().isEmpty ? null : _isbn.text.trim(),
        publisher: _publisher.text.trim().isEmpty
            ? null
            : _publisher.text.trim(),
        publishedYear: publishedYear,
        edition: _edition.text.trim().isEmpty ? null : _edition.text.trim(),
        language: _language.text.trim().isEmpty
            ? 'English'
            : _language.text.trim(),
        pages: pages,
        subjects: subjects,
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        shelf: _shelf.text.trim().isEmpty ? null : _shelf.text.trim(),
        lendable: _lendable,
        replacementCostText: _replacementCost.text,
        initialCopies: initialCopies,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (error) {
      if (!mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppFormModal(
      title: _isEditing ? l10n.titleFormEditHeading : l10n.titleFormNewHeading,
      width: AppDialogWidth.xxxl,
      actions: [
        AppDialog.secondaryAction(
          context: context,
          label: l10n.commonCancel,
          onPressed: _close,
        ),
        AppDialog.primaryAction(
          context: context,
          label: l10n.titleFormSave,
          isLoading: widget.isSaving,
          onPressed: () => unawaited(_save()),
        ),
      ],
      children: [
        AppFormSection(
          title: l10n.titleFormBibliographic,
          description: l10n.titleFormBibliographicDescription,
          children: [
            AppTextField(
              label: l10n.fieldTitle,
              required: true,
              controller: _title,
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
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldPublisher,
                  controller: _publisher,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {},
                ),
              ],
            ),
            AppFormRow(
              children: [
                AppTextField(
                  label: l10n.fieldPublishedYear,
                  controller: _year,
                  keyboardType: TextInputType.number,
                  onChanged: (_) {},
                ),
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
            AppFormRow(
              children: [
                AppDropdownField<TitleFormat>(
                  label: l10n.fieldFormat,
                  value: _selectedFormat,
                  items: widget.formats,
                  itemLabel: (format) => format.label(l10n),
                  itemIcon: (format) => format.icon,
                  onChanged: (format) => setState(
                    () => _formatId = format?.id ?? _formatId,
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
        if (!_isEditing)
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
    );
  }
}
