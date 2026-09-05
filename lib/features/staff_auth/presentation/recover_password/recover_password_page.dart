import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:khulla/core/lifecycle/dispose_bag.dart';
import 'package:khulla/core/router/routes.dart';
import 'package:khulla/features/staff_auth/presentation/auth_labels.dart';
import 'package:khulla/features/staff_auth/presentation/recover_password/cubit/recover_password_cubit.dart';
import 'package:khulla/features/staff_auth/presentation/recover_password/cubit/recover_password_state.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_error_notice.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_header.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_password_field.dart';
import 'package:khulla/features/staff_auth/presentation/widgets/auth_scaffold.dart';
import 'package:khulla/l10n/l10n.dart';
import 'package:khulla_ui/khulla_ui.dart';

/// Sets a new administrator password using a one-time recovery code.
class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage>
    with DisposeBag {
  late final TextEditingController _email = textController();
  late final TextEditingController _recoveryCode = textController();
  late final TextEditingController _password = textController();
  late final TextEditingController _confirmPassword = textController();

  void _submit() =>
      context.read<RecoverPasswordCubit>().resetPasswordWithRecoveryCode();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final spacing = context.appSpacing;

    return AuthScaffold(
      child: BlocBuilder<RecoverPasswordCubit, RecoverPasswordState>(
        builder: (context, state) {
          final cubit = context.read<RecoverPasswordCubit>();
          final error = state.error;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: l10n.recoverPasswordHeading,
                description: l10n.recoverPasswordSubtitle,
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
              AppTextField(
                label: l10n.recoverPasswordCodeLabel,
                hintText: l10n.recoverPasswordCodeHint,
                required: true,
                controller: _recoveryCode,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                errorText: state.recoveryCode.messageFor(l10n),
                onChanged: cubit.recoveryCodeChanged,
              ),
              SizedBox(height: spacing.sm),
              AuthPasswordField(
                label: l10n.recoverPasswordNewPassword,
                controller: _password,
                textInputAction: TextInputAction.next,
                errorText: state.password.messageFor(l10n),
                onChanged: cubit.passwordChanged,
              ),
              SizedBox(height: spacing.sm),
              AuthPasswordField(
                label: l10n.fieldConfirmPassword,
                controller: _confirmPassword,
                textInputAction: TextInputAction.done,
                errorText: state.confirmPassword.messageFor(l10n),
                onChanged: cubit.confirmPasswordChanged,
                onSubmitted: (_) => _submit(),
              ),
              if (state.credentialsRejected) ...[
                SizedBox(height: spacing.md),
                AuthErrorNotice(message: l10n.recoverPasswordRejected),
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
                child: Text(l10n.recoverPasswordAction),
              ),
              SizedBox(height: spacing.md),
              AppButton(
                variant: AppButtonVariant.link,
                onPressed: () => context.go(Routes.signIn),
                child: Text(l10n.recoverPasswordBackToSignIn),
              ),
            ],
          );
        },
      ),
    );
  }
}
