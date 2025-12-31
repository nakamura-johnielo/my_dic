import 'package:my_dic/core/domain/entity/auth.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class ISignUpUseCase {
  Future<Result<AppAuth>> execute(String email, String password);
}
