import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

class EnsureUserExistsInteractor {
  final IUserRepository _userRepository;

  EnsureUserExistsInteractor(this._userRepository);

  Future<Result<AppUser>> execute(String id) async {
    final user = await _userRepository.getUserById(id);

    return user.when(
        success: (user) => Result.success(user),
        failure: (error) async {
          //未登録なら新規作成して返す
          if (error is NotFoundError) {
            return await _registerNewUser(id);
          }
          return Result.failure(error);
        });
  }

  Future<Result<AppUser>> _registerNewUser(String id) async {
    final newUser = AppUser(id: id);
    final res = await _userRepository.updateUser(newUser);
    return res.when(
        success: (_) => Result.success(newUser),
        failure: (error) => Result.failure(error));
  }
}
