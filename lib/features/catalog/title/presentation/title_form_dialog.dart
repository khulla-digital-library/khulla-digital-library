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
import 'package:khulla/features/catalog/title/presentation/cubit/title/title_form_cubit.dart';
import 'package:khulla/features/catalog/title/presentation/cubit/title/title_form_state.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/presentation/cubit/reference_data_cubit.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The title editor, used for both a new work and an existing one.
///
/// A modal rather than a route — see [AppFormModal]. [TitleFormCubit] loads
/// formats and the existing record, then `saveTitle()` writes the bibliographic
/// fields and, on create, seeds the requested number of copies. Fields that are
/// genuinely independent pair up through [AppFormRow], which stacks them again
/// inside the narrower panel.
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
  String? _titleError;
  String? _authorError;
  String? _formatError;
  String? _costError;
  String? _copiesError;

  bool get _isEditing => widget.titleId != null;

  TitleFormat? get _selectedFormat {
    for (final format in widget.formats) {
      if (format.id == _formatId) return format;
    }
    return widget.formats.isEmpty ? null : widget.formats.first;
  }

  void _close() => Navigator.of(context).pop();

  Future<String?> _askFormatName() {
    return AppFormModal.show<String>(
      context: context,
      builder: (modalContext) => const _CreateFormatForm(),
    );
  }

  Future<void> _addFormat() async {
    final name = await _askFormatName();
    if (name == null || name.isEmpty || !mounted) return;
    final l10n = context.l10n;
    try {
      final format = await context.read<TitleFormCubit>().addFormat(name);
      if (!mounted) return;
      unawaited(context.read<ReferenceDataCubit>().refreshFormats());
      setState(() => _formatId = format.id);
    } on AppException catch (error) {
      if (!mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _title.text.trim();
    final author = _author.text.trim();
    final titleError = title.isEmpty ? l10n.validationFieldRequired : null;
    final authorError = author.isEmpty ? l10n.validationFieldRequired : null;
    final formatError = _formatId.isEmpty ? l10n.validationFieldRequired : null;
    final costError = _replacementCost.text.isValidMoney
        ? null
        : l10n.validationAmountInvalid;
    final copies = int.tryParse(_initialCopies.text);
    final copiesError = _isEditing
        ? null
        : (copies == null || copies < 1 ? l10n.validationCopiesMin : null);

    setState(() {
      _titleError = titleError;
      _authorError = authorError;
      _formatError = formatError;
      _costError = costError;
      _copiesError = copiesError;
    });

    if (titleError != null ||
        authorError != null ||
        formatError != null ||
        costError != null ||
        copiesError != null) {
      return;
    }

    try {
      await context.read<TitleFormCubit>().saveTitle(
        title: title,
        author: author,
        formatId: _formatId,
        isbn: _isbn.text.trim().isEmpty ? null : _isbn.text.trim(),
        publisher: _publisher.text.trim().isEmpty
            ? null
            : _publisher.text.trim(),
        publishedYear: int.tryParse(_year.text.trim()),
        edition: _edition.text.trim().isEmpty ? null : _edition.text.trim(),
        language: _language.text.trim().isEmpty
            ? 'English'
            : _language.text.trim(),
        pages: int.tryParse(_pages.text.trim()),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        shelf: _shelf.text.trim().isEmpty ? null : _shelf.text.trim(),
        lendable: _lendable,
        replacementCostText: _replacementCost.text,
        initialCopies: _isEditing ? 0 : copies!,
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
          children: [
            AppFormRow(
              flexes: const [3, 2],
              children: [
                AppTextField(
                  label: l10n.fieldTitle,
                  required: true,
                  controller: _title,
                  errorText: _titleError,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    if (_titleError != null) {
                      setState(() => _titleError = null);
                    }
                  },
                ),
                AppTextField(
                  label: l10n.fieldAuthor,
                  required: true,
                  controller: _author,
                  errorText: _authorError,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) {
                    if (_authorError != null) {
                      setState(() => _authorError = null);
                    }
                  },
                ),
              ],
            ),
            AppFormRow(
              children: [
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
                AppDropdownField<TitleFormat>(
                  label: l10n.fieldFormat,
                  required: true,
                  value: _selectedFormat,
                  items: widget.formats,
                  itemLabel: (format) => format.label(l10n),
                  itemIcon: (format) => format.icon,
                  errorText: _formatError,
                  footerActionLabel: l10n.titleFormAddFormat,
                  onFooterAction: () => unawaited(_addFormat()),
                  onChanged: (format) => setState(() {
                    _formatId = format?.id ?? _formatId;
                    _formatError = null;
                  }),
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
              label: l10n.fieldDescription,
              controller: _description,
              maxLines: 3,
              minLines: 2,
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
              flexes: _isEditing ? null : const [2, 2, 0],
              children: [
                AppTextField(
                  label: l10n.fieldShelf,
                  controller: _shelf,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldReplacementCost,
                  controller: _replacementCost,
                  errorText: _costError,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    if (_costError != null) {
                      setState(() => _costError = null);
                    }
                  },
                ),
                if (!_isEditing)
                  AppQuantityField(
                    label: l10n.titleFormInitialCopies,
                    required: true,
                    controller: _initialCopies,
                    errorText: _copiesError,
                    decreaseTooltip: l10n.commonDecrease,
                    increaseTooltip: l10n.commonIncrease,
                    onChanged: (_) {
                      if (_copiesError != null) {
                        setState(() => _copiesError = null);
                      }
                    },
                  ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: 0.4,
                child: AppSwitchField(
                  value: _lendable,
                  label: l10n.titleFormLendable,
                  description: l10n.titleFormLendableDescription,
                  stacked: true,
                  onChanged: (value) => setState(() => _lendable = value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CreateFormatForm extends StatefulWidget {
  const _CreateFormatForm();

  @override
  State<_CreateFormatForm> createState() => _CreateFormatFormState();
}

class _CreateFormatFormState extends State<_CreateFormatForm> with DisposeBag {
  late final TextEditingController _name = textController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppFormModal(
      title: l10n.titleFormCreateFormatHeading,
      width: AppDialogWidth.sm,
      actions: [
        AppDialog.secondaryAction(
          context: context,
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppDialog.primaryAction(
          context: context,
          label: l10n.titleFormAddFormat,
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) {
              setState(() => _error = l10n.validationFieldRequired);
              return;
            }
            Navigator.of(context).pop(name);
          },
        ),
      ],
      children: [
        AppTextField(
          label: l10n.fieldFormat,
          required: true,
          controller: _name,
          errorText: _error,
          autofocus: true,
          maxLength: 60,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
      ],
    );
  }
}
