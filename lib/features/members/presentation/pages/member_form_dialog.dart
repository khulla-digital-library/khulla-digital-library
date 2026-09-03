import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/features/members/domain/member_category.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/features/members/presentation/placeholder/member_record.dart';
import 'package:khulla/features/members/presentation/placeholder/members_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The borrower editor, used for both a new card and an existing one.
///
/// A modal rather than a route — see [AppFormModal]. Three sections in the
/// order the counter fills them: who the person is, how to reach them, and
/// which rules their card runs under. The category sits last because it is
/// the one field with consequences — it decides the loan period, the
/// borrowing limit and the fine rate.
class MemberFormDialog extends StatefulWidget {
  const MemberFormDialog({this.memberId, super.key});

  /// The record being edited, or null for a new borrower.
  final String? memberId;

  /// Opens the editor. Resolves true once saving is wired and the operator
  /// saved, so a list can refresh itself.
  static Future<bool?> show(BuildContext context, {String? memberId}) =>
      AppFormModal.show<bool>(
        context: context,
        builder: (_) => MemberFormDialog(memberId: memberId),
      );

  @override
  State<MemberFormDialog> createState() => _MemberFormDialogState();
}

class _MemberFormDialogState extends State<MemberFormDialog> with DisposeBag {
  late final TextEditingController _name = textController(_existing?.name);
  late final TextEditingController _cardNumber = textController(
    _existing?.cardNumber,
  );
  late final TextEditingController _email = textController(_existing?.email);
  late final TextEditingController _phone = textController(_existing?.phone);
  late final TextEditingController _address = textController(
    _existing?.address,
  );
  late final TextEditingController _dateOfBirth = textController(
    _existing?.dateOfBirth,
  );
  late final TextEditingController _guardian = textController(
    _existing?.guardian,
  );
  late final TextEditingController _notes = textController(_existing?.notes);

  late MemberCategory _category = _existing?.category ?? MemberCategory.public;
  late bool _sendNotices = true;
  late final String _expires = _existing?.expires ?? '01 Sep 2028';

  bool get _isEditing => widget.memberId != null;

  late final MemberRecord? _existing = _isEditing
      ? placeholderMemberById(widget.memberId!)
      : null;

  void _close() => Navigator.of(context).pop();

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
          onPressed: () => showNotWiredToast(context),
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
              textCapitalization: TextCapitalization.words,
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
                AppDropdownField<MemberCategory>(
                  label: l10n.fieldCategory,
                  required: true,
                  value: _category,
                  items: MemberCategory.values,
                  itemLabel: (category) => category.label(l10n),
                  itemIcon: (category) => category.icon,
                  onChanged: (category) =>
                      setState(() => _category = category ?? _category),
                ),
                AppPickerField(
                  label: l10n.fieldExpires,
                  value: _expires,
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
