import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/port/auth_commands.dart';
import 'package:my_dic/features/auth/port/app_auth.dart';

abstract interface class ISignInUseCase implements SignInPort {
  Future<Result<AppAuth>> execute(String email, String password);

  @override
  Future<Result<AppAuth>> signIn(String email, String password) =>
      execute(email, password);
}
