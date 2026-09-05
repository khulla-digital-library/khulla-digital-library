import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/feedback/app_toast.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/cubit/onboarding_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/cubit/onboarding_state.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/widgets/onboarding_account_step.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/widgets/onboarding_library_step.dart';
import 'package:khulla/features/staff_auth/presentation/onboarding/widgets/onboarding_progress.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_error_notice.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_header.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_scaffold.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla/shared/utils/app_exception_l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// First-run setup: the screen a fresh download opens on.
///
/// The router sends the operator here whenever the catalogue holds no staff
/// account, and nowhere else — there is no route out of this page except
/// finishing it, because a library with no administrator has nothing to show.
///
/// Two steps, and the last one signs the new administrator in: making someone
/// type the password they just chose, on the next screen, to reach the app
/// they just set up, is a step that exists only because the code found it
/// convenient.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _completeSetup(BuildContext context) async {
    final l10n = context.l10n;
    try {
      await context.read<OnboardingCubit>().completeSetup();
    } on AppException catch (error) {
      if (!context.mounted) return;
      AppToast.error(
        context,
        message: l10n.onboardingSetupFailed,
        description: error.localizedMessage(l10n),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AuthScaffold(
      child: BlocBuilder<OnboardingCubit, OnboardingState>(
        builder: (context, state) {
          final cubit = context.read<OnboardingCubit>();
          final onFirstStep = state.step.isFirst;
          // A duplicate address is already shown under the email field, so
          // repeating it above the button would be the same sentence twice.
          final error = state.emailTaken ? null : state.error;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingProgress(step: state.step),
              SizedBox(height: spacing.lg),
              AuthHeader(
                title: onFirstStep
                    ? l10n.onboardingLibraryHeading
                    : l10n.onboardingAccountHeading,
                description: onFirstStep
                    ? l10n.onboardingLibrarySubtitle
                    : l10n.onboardingAccountSubtitle,
              ),
              SizedBox(height: spacing.lg),
              if (onFirstStep)
                OnboardingLibraryStep(state: state)
              else
                OnboardingAccountStep(state: state),
              if (error != null) ...[
                SizedBox(height: spacing.md),
                AuthErrorNotice.exception(error),
              ],
              SizedBox(height: spacing.lg),
              if (onFirstStep)
                AppButton(
                  size: AppButtonSize.large,
                  expand: true,
                  trailingIcon: AppIcons.arrowRight,
                  onPressed: cubit.goToNextStep,
                  child: Text(l10n.onboardingContinue),
                )
              else
                Row(
                  children: [
                    AppButton(
                      variant: AppButtonVariant.outline,
                      size: AppButtonSize.large,
                      icon: AppIcons.chevronLeft,
                      onPressed: state.isSubmitting
                          ? null
                          : cubit.goToPreviousStep,
                      child: Text(l10n.onboardingBack),
                    ),
                    SizedBox(width: spacing.sm),
                    Expanded(
                      child: AppButton(
                        size: AppButtonSize.large,
                        expand: true,
                        isLoading: state.isSubmitting,
                        onPressed: () => _completeSetup(context),
                        child: Text(l10n.onboardingFinish),
                      ),
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
