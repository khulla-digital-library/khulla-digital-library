import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:khulla/core/error/app_exception.dart';
import 'package:khulla/features/users/domain/models/staff_member.dart';

part 'auth_state.freezed.dart';

/// Where the app stands before it can show anything.
enum AuthStatus {
  /// The catalogue has not been asked yet. The router holds still rather than
  /// guessing — sending a signed-in operator to sign-in for one frame is
  /// worse than a moment of splash.
  unknown,

  /// No staff account exists: this catalogue has never been set up.
  needsSetup,

  /// The library is set up, but nobody is signed in on this device.
  signedOut,

  /// A staff account is signed in.
  signedIn,
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    StaffMember? staff,
    AppException? error,
  }) = _AuthState;

  const AuthState._();

  /// Whether the catalogue has answered, and the router may redirect.
  bool get isResolved => status != AuthStatus.unknown;

  /// Whether a staff account is signed in on this device.
  bool get isSignedIn => status == AuthStatus.signedIn;
}
