import 'package:formz/formz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/core/form/inputs/confirmed_password.dart';
import 'package:khulla/core/form/inputs/email.dart';
import 'package:khulla/core/form/inputs/full_name.dart';
import 'package:khulla/core/form/inputs/password.dart';
import 'package:khulla/core/form/inputs/required_text.dart';
import 'package:khulla/core/money/currency.dart';

part 'onboarding_state.freezed.dart';

/// The two things first-run setup has to ask for.
///
/// Two, and no more: a branch, an address, opening hours and loan rules all
/// have defaults a library can live with on day one, and every one of them
/// added here is a screen between someone downloading Khulla and cataloguing
/// their first book. They are edited later under Settings.
enum OnboardingStep {
  /// What the library is called, and what it charges in.
  library,

  /// The administrator account that will run it.
  account;

  bool get isFirst => this == OnboardingStep.library;
  bool get isLast => this == OnboardingStep.account;

  /// One-based position, for "Step 1 of 2".
  int get position => index + 1;
}

@freezed
abstract class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default(OnboardingStep.library) OnboardingStep step,
    @Default(RequiredText.pure()) RequiredText libraryName,
    @Default(AppCurrency.npr) AppCurrency currency,
    @Default(FullName.pure()) FullName adminName,
    @Default(Email.pure()) Email email,
    @Default(Password.pure()) Password password,
    @Default(ConfirmedPassword.pure()) ConfirmedPassword confirmPassword,
    @Default(FormzSubmissionStatus.initial) FormzSubmissionStatus status,

    /// Set when the address is already held by an account. On a fresh
    /// catalogue this is all but impossible; on a restored one it is not.
    @Default(false) bool emailTaken,
    AppException? error,
  }) = _OnboardingState;

  const OnboardingState._();

  /// How many steps the wizard has. Read by the progress line so adding a
  /// step does not mean editing a hard-coded "of 2".
  static int get stepCount => OnboardingStep.values.length;

  bool get isLibraryStepValid => libraryName.isValid;

  bool get isAccountStepValid =>
      Formz.validate([adminName, email, password, confirmPassword]);

  /// Whether the button at the foot of the current step is enabled.
  bool get canAdvance => step.isFirst ? isLibraryStepValid : isAccountStepValid;

  bool get isSubmitting => status.isInProgress;
}
