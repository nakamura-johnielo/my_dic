import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IVerifyEmailUseCase {
  Future<Result<void>> execute();
}
