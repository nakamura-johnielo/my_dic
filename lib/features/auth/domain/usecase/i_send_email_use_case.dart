import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class IResetEmailPasswordUseCase {
  Future<Result<void>> execute(String email);
}
