import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/presentation/placeholder/settings_placeholder.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/not_wired_action.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// The rules every new loan is created under.
///
/// The two money fields are edited as major units — the rupees a librarian
/// types — and read back with `text.toMoney()`, which multiplies by 100. The
/// stored value never leaves minor units, which is the only reason a fine
/// accrued daily for a year still adds up exactly.
class LoanRulesPage extends StatefulWidget {
  const LoanRulesPage({super.key});

  @override
  State<LoanRulesPage> createState() => _LoanRulesPageState();
}

class _LoanRulesPageState extends State<LoanRulesPage> with DisposeBag {
  late final TextEditingController _loanPeriod = textController(
    '${placeholderLoanRules.loanPeriodDays}',
  );
  late final TextEditingController _renewals = textController(
    '${placeholderLoanRules.renewalLimit}',
  );
  late final TextEditingController _borrowingLimit = textController(
    '${placeholderLoanRules.borrowingLimit}',
  );
  late final TextEditingController _finePerDay = textController(
    placeholderLoanRules.finePerDay.editable,
  );
  late final TextEditingController _graceDays = textController(
    '${placeholderLoanRules.graceDays}',
  );
  late final TextEditingController _maximumFine = textController(
    placeholderLoanRules.maximumFine.editable,
  );
  late final TextEditingController _holdShelfDays = textController(
    '${placeholderLoanRules.holdShelfDays}',
  );

  late bool _blockOverdue = placeholderLoanRules.blockOverdueBorrowers;
  late bool _autoRenew = placeholderLoanRules.autoRenewWhenUnreserved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    const numberInput = TextInputType.number;

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
              title: l10n.settingsLoanPeriods,
              description: l10n.settingsLoanPeriodsDescription,
              children: [
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldLoanPeriodDays,
                      required: true,
                      controller: _loanPeriod,
                      keyboardType: numberInput,
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldRenewalLimit,
                      controller: _renewals,
                      keyboardType: numberInput,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppTextField(
                  label: l10n.fieldBorrowingLimit,
                  controller: _borrowingLimit,
                  keyboardType: numberInput,
                  onChanged: (_) {},
                ),
                AppSwitchField(
                  value: _autoRenew,
                  label: l10n.settingsLoanAutoRenew,
                  description: l10n.settingsLoanAutoRenewDescription,
                  onChanged: (value) => setState(() => _autoRenew = value),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.settingsLoanFines,
              description: l10n.settingsLoanFinesDescription,
              children: [
                AppFormRow(
                  children: [
                    AppTextField(
                      label: l10n.fieldFinePerDay,
                      controller: _finePerDay,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) {},
                    ),
                    AppTextField(
                      label: l10n.fieldGraceDays,
                      controller: _graceDays,
                      keyboardType: numberInput,
                      onChanged: (_) {},
                    ),
                  ],
                ),
                AppTextField(
                  label: l10n.fieldMaximumFine,
                  controller: _maximumFine,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {},
                ),
                AppSwitchField(
                  value: _blockOverdue,
                  label: l10n.settingsLoanBlockOverdue,
                  description: l10n.settingsLoanBlockOverdueDescription,
                  onChanged: (value) => setState(() => _blockOverdue = value),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            AppFormSection(
              title: l10n.settingsLoanHolds,
              description: l10n.settingsLoanHoldsDescription,
              children: [
                AppTextField(
                  label: l10n.fieldHoldShelfDays,
                  controller: _holdShelfDays,
                  keyboardType: numberInput,
                  onChanged: (_) {},
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
                  child: Text(l10n.settingsLoanRulesSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
