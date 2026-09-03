import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/settings_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// What this installation calls itself, how to reach it, and which currency
/// its amounts are shown in.
///
/// The currency is display only. `kMinorUnitsPerMajor` is fixed at 100 and
/// every amount is stored in minor units — changing the symbol here changes
/// what a fine *reads* as, never what it *is*.
class LibraryProfilePage extends StatefulWidget {
  const LibraryProfilePage({super.key});

  @override
  State<LibraryProfilePage> createState() => _LibraryProfilePageState();
}

class _LibraryProfilePageState extends State<LibraryProfilePage>
    with DisposeBag {
  late final TextEditingController _name = textController(
    placeholderLibraryProfile.name,
  );
  late final TextEditingController _branch = textController(
    placeholderLibraryProfile.branch,
  );
  late final TextEditingController _email = textController(
    placeholderLibraryProfile.email,
  );
  late final TextEditingController _phone = textController(
    placeholderLibraryProfile.phone,
  );
  late final TextEditingController _address = textController(
    placeholderLibraryProfile.address,
  );
  late final TextEditingController _openingHours = textController(
    placeholderLibraryProfile.openingHours,
  );
  late final TextEditingController _currency = textController(
    placeholderLibraryProfile.currencyCode,
  );
  late final TextEditingController _symbol = textController(
    placeholderLibraryProfile.currencySymbol,
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
            AppFormSection(
              title: l10n.settingsLibraryIdentity,
              description: l10n.settingsLibraryIdentityDescription,
              children: [
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldLibraryName,
                      required: true,
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldBranch,
                      controller: _branch,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.settingsLibraryContact,
              description: l10n.settingsLibraryContactDescription,
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
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldAddress,
                      controller: _address,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldOpeningHours,
                      controller: _openingHours,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.settingsLibraryLocale,
              description: l10n.settingsLibraryLocaleDescription,
              children: [
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldCurrency,
                      controller: _currency,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldCurrencySymbol,
                      controller: _symbol,
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: spacing.xlg),
            Row(
              children: [
                AppButton(
                  variant: AppButtonVariant.outline,
                  size: AppButtonSize.medium,
                  onPressed: () => context.go(Routes.settings),
                  child: Text(l10n.commonCancel),
                ),
                const Spacer(),
                AppButton(
                  size: AppButtonSize.medium,
                  onPressed: () => showNotWiredToast(context),
                  child: Text(l10n.settingsLibrarySave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
