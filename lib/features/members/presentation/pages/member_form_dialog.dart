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
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The borrower editor, used for both a new card and an existing one.
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
  late final TextEditingController _dateOfBirth = textController(
    widget.existing?.dateOfBirth == null
        ? null
        : AppDateFormat.format(widget.existing!.dateOfBirth!),
  );
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
        AppFormSection(
          title: l10n.memberFormIdentity,
          description: l10n.memberFormIdentityDescription,
          children: [
            AppTextField(
              label: l10n.fieldFullName,
              required: true,
              controller: _name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {},
            ),
            AppFormRow(
              children: [
                AppTextField(
                  label: l10n.fieldCardNumber,
                  required: true,
                  controller: _cardNumber,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldDateOfBirth,
                  controller: _dateOfBirth,
                  onChanged: (_) {},
                ),
              ],
            ),
            AppTextField(
              label: l10n.fieldGuardian,
              controller: _guardian,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormSection(
          title: l10n.memberDetailContact,
          description: l10n.memberFormContactDescription,
          children: [
            AppFormRow(
              children: [
                AppTextField(
                  label: l10n.fieldEmail,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {},
                ),
                AppTextField(
                  label: l10n.fieldPhone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  onChanged: (_) {},
                ),
              ],
            ),
            AppTextField(
              label: l10n.fieldAddress,
              controller: _address,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormSection(
          title: l10n.memberDetailMembership,
          description: l10n.memberFormMembershipDescription,
          children: [
            AppFormRow(
              children: [
                AppDropdownField<MemberType>(
                  label: l10n.fieldCategory,
                  required: true,
                  value: _selectedType,
                  items: widget.memberTypes,
                  itemLabel: (type) => type.name,
                  itemIcon: (type) => type.code.memberTypeIcon,
                  onChanged: (type) => setState(
                    () => _memberTypeId = type?.id ?? _memberTypeId,
                  ),
                ),
                AppPickerField(
                  label: l10n.fieldExpires,
                  value: _expires.isEmpty ? l10n.commonNotSet : _expires,
                  icon: AppIcons.calendar,
                  onTap: () => showNotWiredToast(context),
                ),
              ],
            ),
            AppTextField(
              label: l10n.fieldNotes,
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {},
            ),
            AppSwitchField(
              value: _sendNotices,
              label: l10n.memberFormNotifications,
              description: l10n.memberFormNotificationsDescription,
              onChanged: (value) => setState(() => _sendNotices = value),
            ),
          ],
        ),
      ],
    );
  }
}
