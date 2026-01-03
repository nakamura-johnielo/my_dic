import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';

class GetUserInteractor implements IGetUserUseCase {
  final IUserRepository _userRepository;

  GetUserInteractor(this._userRepository);

  @override
  Future<Result<AppUser>> execute(String id) async {
    final result = await _userRepository.getUserByAccountId(id);
    
    // NotFoundErrorの場合はデフォルトユーザーを返す
    return result.when(
      success: (user) => Result.success(user),
      failure: (error) {
        return Result.failure(error);
      },
    );
  }
}
