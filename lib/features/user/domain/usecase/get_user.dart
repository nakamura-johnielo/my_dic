import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';

class GetUserInteractor implements IGetUserUseCase {
  final IUserRepository _userRepository;
  final IAuthRepository _authRepository;

  GetUserInteractor(this._userRepository, this._authRepository);

  @override
  Future<Result<AppUser>> execute() async {
    final authRes = await _authRepository.getCurrentAuth();
    String id = "";
    authRes.when(
      success: (auth) {
        if (auth.isAuthenticated && auth.accountId.isNotEmpty) {
          id = auth.accountId;
        }
      },
      failure: (_) {},
    );

    if (id.isEmpty) {
      return Result.failure(
          NotFoundError(message: "User is not authenticated"));
    }

    print("GetUserInteractor execute==================$id");
    final result = await _userRepository.getUserByAccountId(id);

    // NotFoundErrorの場合はデフォルトユーザーを返す
    return result.when(
      success: (user) => Result.success(user),
      failure: (error) {
        print("GetUserInteractor error========${error.message}");
        return Result.failure(error);
      },
    );
  }
}
