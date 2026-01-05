

import 'package:my_dic/core/shared/enums/ui/button_status.dart';

class SignInUIState {
  final ButtonStatus isWaitingSignIn;
  final ButtonStatus isWaitingSignOut;
  final ButtonStatus isWaitingSignUp;
  final ButtonStatus isWaitingResetPassword;
  final ButtonStatus isWaitingVerifyEmail;

  SignInUIState(
      {this.isWaitingSignIn = ButtonStatus.normal,
      this.isWaitingSignOut = ButtonStatus.normal,
      this.isWaitingSignUp = ButtonStatus.normal,
      this.isWaitingResetPassword = ButtonStatus.normal,
      this.isWaitingVerifyEmail = ButtonStatus.normal, });

  SignInUIState copyWith({
    ButtonStatus? isWaitingSignIn,
    ButtonStatus? isWaitingSignOut,
    ButtonStatus? isWaitingSignUp,
    ButtonStatus? isWaitingResetPassword,
    ButtonStatus? isWaitingVerifyEmail,
  }) {
    return SignInUIState(
      isWaitingSignIn: isWaitingSignIn ?? this.isWaitingSignIn,
      isWaitingSignOut: isWaitingSignOut ?? this.isWaitingSignOut,
      isWaitingSignUp: isWaitingSignUp ?? this.isWaitingSignUp,
      isWaitingResetPassword:
          isWaitingResetPassword ?? this.isWaitingResetPassword,
      isWaitingVerifyEmail: isWaitingVerifyEmail ?? this.isWaitingVerifyEmail,
    );
  }
}
