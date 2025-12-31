import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';

abstract interface class IGetUserUseCase {
  Future<Result<AppUser>> execute(String id);
}
