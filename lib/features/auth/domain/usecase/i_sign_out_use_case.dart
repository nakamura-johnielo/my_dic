import 'package:my_dic/core/shared/utils/result.dart';

abstract interface class ISignOutUseCase {
  Future<Result<void>> execute();
}
