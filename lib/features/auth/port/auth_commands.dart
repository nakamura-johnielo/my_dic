import 'package:my_dic/core/shared/utils/result.dart';

import 'app_auth.dart';

/// Public commands for changing Auth state.
abstract interface class SignInPort {
  Future<Result<AppAuth>> signIn(String email, String password);
}

abstract interface class SignUpPort {
  Future<Result<AppAuth>> signUp(String email, String password);
}

abstract interface class SignOutPort {
  Future<Result<void>> signOut();
}

abstract interface class SendVerificationEmailPort {
  Future<Result<void>> sendVerificationEmail();
}
