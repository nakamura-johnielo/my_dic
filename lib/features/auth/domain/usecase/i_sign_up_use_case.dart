import 'package:my_dic/features/auth/domain/entity/app_auth.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class ISignUpUseCase {
  Future<Result<AppAuth>> execute(String email, String password);
}
