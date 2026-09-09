import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Who the person is: name and card number, then birth date and guardian.
///
/// The date picker caps at today and the clear action empties the field;
/// the state owns both.
class MemberFormIdentitySection extends StatelessWidget {
  const MemberFormIdentitySection({
    required this.name,
    required this.cardNumber,
    required this.dateOfBirth,
    required this.guardian,
    required this.onPickDateOfBirth,
    required this.onClearDateOfBirth,
    super.key,
  });

  final TextEditingController name;
  final TextEditingController cardNumber;
  final String? dateOfBirth;
  final TextEditingController guardian;
  final VoidCallback onPickDateOfBirth;
  final VoidCallback? onClearDateOfBirth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppFormSection(
      title: l10n.memberFormIdentity,
      children: [
        AppFormRow(
          flexes: const [3, 2],
          children: [
            AppTextField(
              label: l10n.fieldFullName,
              required: true,
              controller: name,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldCardNumber,
              required: true,
              controller: cardNumber,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormRow(
          flexes: const [2, 3],
          children: [
            AppPickerField(
              label: l10n.fieldDateOfBirth,
              value: dateOfBirth,
              icon: AppIcons.calendar,
              onTap: onPickDateOfBirth,
              onClear: onClearDateOfBirth,
              clearTooltip: l10n.commonClear,
            ),
            AppTextField(
              label: l10n.fieldGuardian,
              controller: guardian,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}

/// How to reach them: email and phone, then the address.
class MemberFormContactSection extends StatelessWidget {
  const MemberFormContactSection({
    required this.email,
    required this.phone,
    required this.address,
    super.key,
  });

  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController address;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppFormSection(
      title: l10n.memberDetailContact,
      children: [
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldEmail,
              controller: email,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldPhone,
              controller: phone,
              keyboardType: TextInputType.phone,
              onChanged: (_) {},
            ),
          ],
        ),
        AppTextField(
          label: l10n.fieldAddress,
          controller: address,
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) {},
        ),
      ],
    );
  }
}
