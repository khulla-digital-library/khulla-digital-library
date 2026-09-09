import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/format/app_date_format.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/features/members/domain/models/member.dart';
import 'package:khulla/features/members/domain/models/member_type.dart';
import 'package:khulla/features/members/presentation/cubit/member_form_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_form_state.dart';
import 'package:khulla/features/members/presentation/widgets/create_category_form.dart';
import 'package:khulla/features/members/presentation/widgets/member_form_membership_section.dart';
import 'package:khulla/features/members/presentation/widgets/member_form_sections.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/presentation/cubit/reference_data_cubit.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The borrower editor, used for both a new card and an existing one.
///
/// A modal rather than a route — see [AppFormModal]. Three sections in the
/// order the counter fills them: who the person is, how to reach them, and
/// which rules their card runs under. [MemberFormCubit] loads member types and
/// saves the record; the category sits last because it decides the loan period,
/// borrowing limit and fine rate. Expiry is read-only here — it is set from
/// the loan rules on registration and extended by renewing the membership.
class MemberFormDialog extends StatelessWidget {
  const MemberFormDialog({this.memberId, super.key});

  final String? memberId;

  static Future<bool?> show(BuildContext context, {String? memberId}) =>
      AppFormModal.show<bool>(
        context: context,
        builder: (_) => BlocProvider(
          create: (_) {
            final cubit = getIt<MemberFormCubit>();
            unawaited(cubit.load(memberId: memberId));
            return cubit;
          },
          child: MemberFormDialog(memberId: memberId),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEditing = memberId != null;

    return BlocBuilder<MemberFormCubit, MemberFormState>(
      builder: (context, state) {
        if (state.isLoading) {
          return AppFormModal(
            title: isEditing
                ? l10n.memberFormEditHeading
                : l10n.memberFormNewHeading,
            width: AppDialogWidth.xxxl,
            actions: const [],
            children: const [Center(child: AppSpinner())],
          );
        }

        return _MemberFormBody(
          key: ValueKey(memberId ?? 'new'),
          memberId: memberId,
          existing: state.existing,
          memberTypes: state.memberTypes,
          isSaving: state.isSaving,
        );
      },
    );
  }
}

class _MemberFormBody extends StatefulWidget {
  const _MemberFormBody({
    required this.memberId,
    required this.existing,
    required this.memberTypes,
    required this.isSaving,
    super.key,
  });

  final String? memberId;
  final Member? existing;
  final List<MemberType> memberTypes;
  final bool isSaving;

  @override
  State<_MemberFormBody> createState() => _MemberFormBodyState();
}

class _MemberFormBodyState extends State<_MemberFormBody> with DisposeBag {
  late final TextEditingController _name = textController(
    widget.existing?.fullName,
  );
  late final TextEditingController _cardNumber = textController(
    widget.existing?.cardNumber,
  );
  late final TextEditingController _email = textController(
    widget.existing?.email,
  );
  late final TextEditingController _phone = textController(
    widget.existing?.phone,
  );
  late final TextEditingController _address = textController(
    widget.existing?.address,
  );
  late DateTime? _dateOfBirth = widget.existing?.dateOfBirth;
  late final TextEditingController _guardian = textController(
    widget.existing?.guardian,
  );
  late final TextEditingController _notes = textController(
    widget.existing?.notes,
  );

  late String _memberTypeId =
      widget.existing?.memberTypeId ??
      (widget.memberTypes.isNotEmpty ? widget.memberTypes.first.id : '');
  late bool _sendNotices = widget.existing?.sendNotices ?? true;
  late final String _expires = widget.existing?.expires ?? '';

  bool get _isEditing => widget.memberId != null;

  MemberType? get _selectedType {
    for (final type in widget.memberTypes) {
      if (type.id == _memberTypeId) return type;
    }
    return widget.memberTypes.isEmpty ? null : widget.memberTypes.first;
  }

  void _close() => Navigator.of(context).pop();

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(today.year - 18),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (picked == null || !mounted) return;
    setState(
      () => _dateOfBirth = DateTime(picked.year, picked.month, picked.day),
    );
  }

  Future<String?> _askCategoryName() {
    return AppFormModal.show<String>(
      context: context,
      builder: (modalContext) => const CreateCategoryForm(),
    );
  }

  Future<void> _addCategory() async {
    final name = await _askCategoryName();
    if (name == null || name.isEmpty || !mounted) return;
    final l10n = context.l10n;
    try {
      final type = await context.read<MemberFormCubit>().addMemberType(name);
      if (!mounted) return;
      unawaited(context.read<ReferenceDataCubit>().refreshMemberTypes());
      setState(() => _memberTypeId = type.id);
    } on AppException catch (error) {
      if (!mounted) return;
      AppToast.error(context, message: error.localizedMessage(l10n));
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final cardNumber = _cardNumber.text.trim();
    if (name.isEmpty || cardNumber.isEmpty || _memberTypeId.isEmpty) {
      AppToast.error(context, message: l10n.validationFieldRequired);
      return;
    }
    try {
      await context.read<MemberFormCubit>().saveMember(
        fullName: name,
        cardNumber: cardNumber,
        memberTypeId: _memberTypeId,
        sendNotices: _sendNotices,
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
        dateOfBirthText: _dateOfBirth == null
            ? null
            : AppDateFormat.format(_dateOfBirth!),
        guardian: _guardian.text.trim().isEmpty ? null : _guardian.text.trim(),
        notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
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
      title: _isEditing
          ? l10n.memberFormEditHeading
          : l10n.memberFormNewHeading,
      width: AppDialogWidth.xxxl,
      actions: [
        AppDialog.secondaryAction(
          context: context,
          label: l10n.commonCancel,
          onPressed: _close,
        ),
        AppDialog.primaryAction(
          context: context,
          label: l10n.memberFormSave,
          isLoading: widget.isSaving,
          onPressed: () => unawaited(_save()),
        ),
      ],
      children: [
        MemberFormIdentitySection(
          name: _name,
          cardNumber: _cardNumber,
          dateOfBirth: _dateOfBirth == null
              ? null
              : AppDateFormat.format(_dateOfBirth!),
          guardian: _guardian,
          onPickDateOfBirth: () => unawaited(_pickDateOfBirth()),
          onClearDateOfBirth: _dateOfBirth == null
              ? null
              : () => setState(() => _dateOfBirth = null),
        ),
        MemberFormContactSection(
          email: _email,
          phone: _phone,
          address: _address,
        ),
        MemberFormMembershipSection(
          memberTypes: widget.memberTypes,
          selectedType: _selectedType,
          expires: _expires,
          notes: _notes,
          sendNotices: _sendNotices,
          onTypeChanged: (type) => setState(
            () => _memberTypeId = type?.id ?? _memberTypeId,
          ),
          onAddCategory: () => unawaited(_addCategory()),
          onSendNoticesChanged: (value) => setState(() => _sendNotices = value),
        ),
      ],
    );
  }
}
