import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/features/staff_auth/presentation/auth_labels.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/cubit/sign_in_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/sign_in/cubit/sign_in_state.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_error_notice.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_header.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_password_field.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_scaffold.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Sign-in for a library that has already been set up.
///
/// The router sends the operator here whenever staff accounts exist and
/// nobody is signed in on this device; there is no way to reach it otherwise,
/// and no link from here to onboarding — a second administrator is created
/// from the staff section, not from this screen.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with DisposeBag {
  late final TextEditingController _email = textController();
  late final TextEditingController _password = textController();

  void _submit() => context.read<SignInCubit>().signIn();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;
    final colors = context.appColors;
    final typography = context.appTextStyles;

    return AuthScaffold(
      child: BlocBuilder<SignInCubit, SignInState>(
        builder: (context, state) {
          final cubit = context.read<SignInCubit>();
          final error = state.error;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: l10n.signInHeading,
                description: l10n.signInSubtitle,
              ),
              SizedBox(height: spacing.lg),
              AppTextField(
                label: l10n.fieldEmail,
                required: true,
                controller: _email,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                errorText: state.email.messageFor(l10n),
                onChanged: cubit.emailChanged,
              ),
              SizedBox(height: spacing.sm),
              AuthPasswordField(
                label: l10n.fieldPassword,
                controller: _password,
                textInputAction: TextInputAction.done,
                errorText: state.password.messageFor(l10n),
                onChanged: cubit.passwordChanged,
                onSubmitted: (_) => _submit(),
              ),
              if (state.credentialsRejected) ...[
                SizedBox(height: spacing.md),
                AuthErrorNotice(message: l10n.signInRejected),
              ],
              if (error != null) ...[
                SizedBox(height: spacing.md),
                AuthErrorNotice.exception(error),
              ],
              SizedBox(height: spacing.lg),
              AppButton(
                size: AppButtonSize.large,
                expand: true,
                isLoading: state.isSubmitting,
                onPressed: _submit,
                child: Text(l10n.signInAction),
              ),
              SizedBox(height: spacing.md),
              Text(
                l10n.signInForgotPassword,
                textAlign: TextAlign.center,
                style: typography.caption.copyWith(color: colors.textMuted),
              ),
            ],
          );
        },
      ),
    );
  }
}
