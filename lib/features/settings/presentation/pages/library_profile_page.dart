import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/money/currency.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/settings/domain/models/library_profile.dart';
import 'package:khulla/features/settings/presentation/cubit/library_profile_cubit.dart';
import 'package:khulla/features/settings/presentation/cubit/library_profile_state.dart';
import 'package:khulla/features/staff_auth/presentation/auth_labels.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla/shared/widgets/error_retry_view.dart';
import 'package:khulla_ui/khulla_ui.dart';

class LibraryProfilePage extends StatefulWidget {
  const LibraryProfilePage({super.key});

  @override
  State<LibraryProfilePage> createState() => _LibraryProfilePageState();
}

class _LibraryProfilePageState extends State<LibraryProfilePage>
    with DisposeBag {
  late final TextEditingController _name = textController();
  late final TextEditingController _branch = textController();
  late final TextEditingController _email = textController();
  late final TextEditingController _phone = textController();
  late final TextEditingController _address = textController();
  late final TextEditingController _openingHours = textController();

  AppCurrency _currency = AppCurrency.npr;
  LibraryProfile? _loadedProfile;

  void _syncFromProfile(LibraryProfile profile) {
    if (_loadedProfile?.updatedAt == profile.updatedAt &&
        _loadedProfile?.name == profile.name) {
      return;
    }
    _loadedProfile = profile;
    _name.text = profile.name;
    _branch.text = profile.branch ?? '';
    _email.text = profile.email ?? '';
    _phone.text = profile.phone ?? '';
    _address.text = profile.address ?? '';
    _openingHours.text = profile.openingHours ?? '';
    _currency = profile.currency;
  }

  Future<void> _save(BuildContext context) async {
    final l10n = context.l10n;
    if (_name.text.trim().isEmpty) {
      AppToast.error(context, message: l10n.validationFieldRequired);
      return;
    }

    try {
      await context.read<LibraryProfileCubit>().saveProfile(
        name: _name.text,
        currency: _currency,
        branch: _branch.text,
        email: _email.text,
        phone: _phone.text,
        address: _address.text,
        openingHours: _openingHours.text,
      );
      if (!context.mounted) return;
      AppToast.success(context, message: l10n.settingsLibrarySave);
      context.go(Routes.settings);
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(
        context,
        message: error.localizedMessage(l10n),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return BlocConsumer<LibraryProfileCubit, LibraryProfileState>(
      listenWhen: (previous, current) => current.profile != previous.profile,
      listener: (context, state) {
        final profile = state.profile;
        if (profile != null) _syncFromProfile(profile);
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const AppPageBody(
            wide: true,
            child: Center(child: AppSpinner()),
          );
        }
        if (state.hasError) {
          return AppPageBody(
            wide: true,
            child: ErrorRetryView(
              error: state.error,
              onRetry: context.read<LibraryProfileCubit>().loadProfile,
            ),
          );
        }
        if (state.profile == null) {
          return AppPageBody(
            wide: true,
            child: AppEmptyView(
              icon: AppIcons.settings,
              title: l10n.settingsLibraryIdentity,
              message: l10n.onboardingLibrarySubtitle,
            ),
          );
        }

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
                    AppDropdownField<AppCurrency>(
                      label: l10n.fieldCurrency,
                      required: true,
                      value: _currency,
                      items: AppCurrency.values,
                      itemLabel: (currency) => currency.label(l10n),
                      searchHint: l10n.currencySearchHint,
                      clearSearchTooltip: l10n.commonClearSearch,
                      emptySearchMessage: l10n.commonNoMatchesTitle,
                      itemMatchesSearch: (currency, query) =>
                          currency.name.toLowerCase().contains(query) ||
                          currency.code.toLowerCase().contains(query),
                      onChanged: (currency) {
                        if (currency != null) {
                          setState(() => _currency = currency);
                        }
                      },
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
                      isLoading: state.isSaving,
                      onPressed: state.isSaving
                          ? null
                          : () => unawaited(_save(context)),
                      child: Text(l10n.settingsLibrarySave),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
