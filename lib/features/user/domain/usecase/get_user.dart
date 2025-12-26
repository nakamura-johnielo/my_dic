import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

class GetUserInteractor {
  final IUserRepository _userRepository;

  GetUserInteractor(this._userRepository);

  Future<Result<AppUser>> execute(String id) async {
    final result = await _userRepository.getUserById(id);
    
    // NotFoundErrorの場合はデフォルトユーザーを返す
    return result.when(
      success: (user) => Result.success(user),
      failure: (error) {
        if (error is NotFoundError) {
          return Result.success(AppUser(id: id));
        }
        return Result.failure(error);
      },
    );
  }
}
