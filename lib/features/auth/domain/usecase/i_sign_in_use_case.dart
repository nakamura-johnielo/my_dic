
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/entity/app_auth.dart';

abstract interface class ISignInUseCase {
  Future<Result<AppAuth>> execute(String email, String password);
}
