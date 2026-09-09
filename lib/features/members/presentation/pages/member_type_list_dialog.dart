import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/di/injection.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/money/money.dart';
import 'package:khulla/features/members/domain/models/member_type.dart';
import 'package:khulla/features/members/presentation/cubit/member_type_cubit.dart';
import 'package:khulla/features/members/presentation/cubit/member_type_state.dart';
import 'package:khulla/features/members/presentation/member_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Lists member categories and lets staff create, edit, archive or restore
/// them — including the loan-rule overrides each one carries.
abstract final class MemberTypeListDialog {
  static Future<void> show(BuildContext context) {
    final l10n = context.l10n;
    final cubit = getIt<MemberTypeCubit>();
    unawaited(cubit.loadTypes());
    return AppSideSheet.show<void>(
      context: context,
      title: l10n.membersManageCategories,
      caption: l10n.membersManageCategoriesBody,
      closeTooltip: l10n.commonClose,
      width: 560,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _MemberTypeSheetBody(),
      ),
      actionsBuilder: (_) => BlocProvider.value(
        value: cubit,
        child: const _MemberTypeSheetActions(),
      ),
    ).whenComplete(cubit.close);
  }
}

class _MemberTypeSheetBody extends StatelessWidget {
  const _MemberTypeSheetBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemberTypeCubit, MemberTypeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: AppSpinner());
        }
        if (state.hasError) {
          return ErrorRetryView(
            error: state.error,
            onRetry: context.read<MemberTypeCubit>().loadTypes,
          );
        }
        return _MemberTypeList(types: state.types);
      },
    );
  }
}

class _MemberTypeSheetActions extends StatelessWidget {
  const _MemberTypeSheetActions();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppDialogActions(
      children: [
        AppDialog.primaryAction(
          context: context,
          label: l10n.memberTypeAddCategory,
          onPressed: () => unawaited(_addType(context)),
        ),
      ],
    );
  }
}

class _MemberTypeList extends StatelessWidget {
  const _MemberTypeList({required this.types});

  final List<MemberType> types;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final activeCount = types.where((type) => !type.isArchived).length;

    if (types.isEmpty) {
      return AppEmptyView(
        variant: AppFeedbackVariant.inline,
        title: l10n.memberTypesEmptyTitle,
        message: l10n.memberTypesEmptyBody,
        actionLabel: l10n.memberTypeAddCategory,
        onAction: () => unawaited(_addType(context)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final type in types)
          Padding(
            padding: EdgeInsets.only(bottom: context.appSpacing.sm),
            child: _MemberTypeRow(
              type: type,
              canArchive: !type.isArchived && activeCount > 1,
            ),
          ),
      ],
    );
  }
}

class _MemberTypeRow extends StatelessWidget {
  const _MemberTypeRow({required this.type, required this.canArchive});

  final MemberType type;
  final bool canArchive;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = context.colorScheme;
    final spacing = context.appSpacing;
    final muted = context.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return AppCard(
      child: Row(
        children: [
          AppIcon(
            type.code.memberTypeIcon,
            size: spacing.md,
            color: scheme.onSurfaceVariant,
          ),
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        type.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (type.isSystem) ...[
                      SizedBox(width: spacing.xs),
                      AppStatusBadge(
                        dense: true,
                        label: l10n.memberTypeSystemBadge,
                      ),
                    ],
                    if (type.isArchived) ...[
                      SizedBox(width: spacing.xs),
                      AppStatusBadge(
                        dense: true,
                        label: l10n.memberTypeArchivedBadge,
                        tone: AppStatusTone.warning,
                      ),
                    ],
                  ],
                ),
                Text(_overridesSummary(l10n), style: muted),
              ],
            ),
          ),
          if (type.isArchived)
            AppTextButton(
              onPressed: () => unawaited(_restoreType(context, type)),
              child: Text(l10n.memberTypeRestoreAction),
            )
          else ...[
            AppIconButton(
              icon: AppIcons.edit,
              tooltip: l10n.commonEdit,
              size: AppIconButtonSize.small,
              onPressed: () => unawaited(_saveType(context, type)),
            ),
            AppIconButton(
              icon: AppIcons.delete,
              tooltip: l10n.commonArchive,
              size: AppIconButtonSize.small,
              tone: AppStatusTone.danger,
              onPressed: canArchive
                  ? () => unawaited(_archiveType(context, type))
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  String _overridesSummary(AppLocalizations l10n) {
    final parts = <String>[
      if (type.loanPeriodDays != null) l10n.fieldLoanPeriodDays,
      if (type.borrowingLimit != null) l10n.fieldBorrowingLimit,
      if (type.finePerDay != null) l10n.fieldFinePerDay,
      if (type.membershipDurationMonths != null)
        l10n.fieldMembershipDurationMonths,
    ];
    return parts.isEmpty
        ? l10n.memberFormMembershipDescription
        : parts.join(' · ');
  }
}

Future<void> _addType(BuildContext context) async {
  final l10n = context.l10n;
  final draft = await _MemberTypeFormDialog.show(
    context,
    heading: l10n.memberTypeCreateHeading,
    confirmLabel: l10n.memberTypeAddCategory,
  );
  if (draft == null || !context.mounted) return;
  try {
    await context.read<MemberTypeCubit>().addType(draft);
  } on AppException catch (error) {
    if (!context.mounted) return;
    AppToast.error(context, message: error.localizedMessage(l10n));
  }
}

Future<void> _saveType(BuildContext context, MemberType type) async {
  final l10n = context.l10n;
  final draft = await _MemberTypeFormDialog.show(
    context,
    heading: l10n.memberTypeEditHeading,
    confirmLabel: l10n.commonSave,
    existing: type,
  );
  if (draft == null || !context.mounted) return;
  try {
    await context.read<MemberTypeCubit>().saveType(draft);
  } on AppException catch (error) {
    if (!context.mounted) return;
    AppToast.error(context, message: error.localizedMessage(l10n));
  }
}

Future<void> _archiveType(BuildContext context, MemberType type) async {
  final l10n = context.l10n;
  final confirmed = await AppDialog.confirmDestructive(
    context: context,
    title: l10n.memberTypeArchiveTitle,
    message: l10n.memberTypeArchiveBody,
    confirmLabel: l10n.commonArchive,
    cancelLabel: l10n.commonCancel,
  );
  if (!context.mounted || !confirmed) return;
  try {
    await context.read<MemberTypeCubit>().archiveType(type.id);
  } on AppException catch (error) {
    if (!context.mounted) return;
    AppToast.error(context, message: error.localizedMessage(l10n));
  }
}

Future<void> _restoreType(BuildContext context, MemberType type) async {
  final l10n = context.l10n;
  try {
    await context.read<MemberTypeCubit>().unarchiveType(type.id);
  } on AppException catch (error) {
    if (!context.mounted) return;
    AppToast.error(context, message: error.localizedMessage(l10n));
  }
}

class _MemberTypeFormDialog extends StatefulWidget {
  const _MemberTypeFormDialog({
    required this.heading,
    required this.confirmLabel,
    this.existing,
  });

  final String heading;
  final String confirmLabel;
  final MemberType? existing;

  static Future<MemberType?> show(
    BuildContext context, {
    required String heading,
    required String confirmLabel,
    MemberType? existing,
  }) => AppFormModal.show<MemberType>(
    context: context,
    builder: (_) => _MemberTypeFormDialog(
      heading: heading,
      confirmLabel: confirmLabel,
      existing: existing,
    ),
  );

  @override
  State<_MemberTypeFormDialog> createState() => _MemberTypeFormDialogState();
}

class _MemberTypeFormDialogState extends State<_MemberTypeFormDialog>
    with DisposeBag {
  late final TextEditingController _name = textController(
    widget.existing?.name,
  );
  late final TextEditingController _loanPeriodDays = textController(
    widget.existing?.loanPeriodDays?.toString(),
  );
  late final TextEditingController _borrowingLimit = textController(
    widget.existing?.borrowingLimit?.toString(),
  );
  late final TextEditingController _renewalLimit = textController(
    widget.existing?.renewalLimit?.toString(),
  );
  late final TextEditingController _renewalPeriodDays = textController(
    widget.existing?.renewalPeriodDays?.toString(),
  );
  late final TextEditingController _finePerDay = textController(
    widget.existing?.finePerDay?.editable,
  );
  late final TextEditingController _graceDays = textController(
    widget.existing?.graceDays?.toString(),
  );
  late final TextEditingController _maximumFinePerCopy = textController(
    widget.existing?.maximumFinePerCopy?.editable,
  );
  late final TextEditingController _maxOutstandingFine = textController(
    widget.existing?.maxOutstandingFine?.editable,
  );
  late final TextEditingController _membershipDurationMonths = textController(
    widget.existing?.membershipDurationMonths?.toString(),
  );
  late final TextEditingController _reservationLimit = textController(
    widget.existing?.reservationLimit?.toString(),
  );

  int? _parseInt(String text) =>
      text.trim().isEmpty ? null : int.tryParse(text.trim());

  bool _validMoney(String text) => text.trim().isEmpty || text.isValidMoney;

  void _submit() {
    final l10n = context.l10n;
    final name = _name.text.trim();
    if (name.isEmpty ||
        !_validMoney(_finePerDay.text) ||
        !_validMoney(_maximumFinePerCopy.text) ||
        !_validMoney(_maxOutstandingFine.text)) {
      AppToast.error(context, message: l10n.validationFieldRequired);
      return;
    }

    final existing = widget.existing;
    final draft = MemberType(
      id: existing?.id ?? '',
      name: name,
      sortOrder: existing?.sortOrder ?? 0,
      isSystem: existing?.isSystem ?? false,
      createdAt: existing?.createdAt ?? DateTime.now(),
      code: existing?.code,
      archivedAt: existing?.archivedAt,
      loanPeriodDays: _parseInt(_loanPeriodDays.text),
      borrowingLimit: _parseInt(_borrowingLimit.text),
      renewalLimit: _parseInt(_renewalLimit.text),
      renewalPeriodDays: _parseInt(_renewalPeriodDays.text),
      finePerDay: _finePerDay.text.trim().isEmpty
          ? null
          : _finePerDay.text.toMoney(),
      graceDays: _parseInt(_graceDays.text),
      maximumFinePerCopy: _maximumFinePerCopy.text.trim().isEmpty
          ? null
          : _maximumFinePerCopy.text.toMoney(),
      maxOutstandingFine: _maxOutstandingFine.text.trim().isEmpty
          ? null
          : _maxOutstandingFine.text.toMoney(),
      membershipDurationMonths: _parseInt(_membershipDurationMonths.text),
      reservationLimit: _parseInt(_reservationLimit.text),
    );
    Navigator.of(context).pop(draft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const numberInput = TextInputType.number;
    const moneyInput = TextInputType.numberWithOptions(decimal: true);

    return AppFormModal(
      title: widget.heading,
      description: l10n.membersManageCategoriesBody,
      width: AppDialogWidth.xxxl,
      actions: [
        AppDialog.secondaryAction(
          context: context,
          label: l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AppDialog.primaryAction(
          context: context,
          label: widget.confirmLabel,
          onPressed: _submit,
        ),
      ],
      children: [
        AppTextField(
          label: l10n.fieldCategory,
          required: true,
          controller: _name,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: (_) {},
        ),
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldLoanPeriodDays,
              controller: _loanPeriodDays,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldBorrowingLimit,
              controller: _borrowingLimit,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldRenewalLimit,
              controller: _renewalLimit,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldRenewalPeriodDays,
              controller: _renewalPeriodDays,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldFinePerDay,
              controller: _finePerDay,
              keyboardType: moneyInput,
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
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldMaximumFine,
              controller: _maximumFinePerCopy,
              keyboardType: moneyInput,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldMaxOutstandingFine,
              controller: _maxOutstandingFine,
              keyboardType: moneyInput,
              onChanged: (_) {},
            ),
          ],
        ),
        AppFormRow(
          children: [
            AppTextField(
              label: l10n.fieldMembershipDurationMonths,
              controller: _membershipDurationMonths,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
            AppTextField(
              label: l10n.fieldReservationLimit,
              controller: _reservationLimit,
              keyboardType: numberInput,
              onChanged: (_) {},
            ),
          ],
        ),
      ],
    );
  }
}
