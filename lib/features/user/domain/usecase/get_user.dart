import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_get_user_use_case.dart';

class GetUserInteractor implements IGetUserUseCase {
  final IUserRepository _userRepository;
  final CurrentSession _currentSession;

  GetUserInteractor(this._userRepository, this._currentSession);

  @override
  Future<Result<AppUser>> execute() async {
    final id = _currentSession.accountIdOrNull ?? "";

    if (id.isEmpty) {
      return Result.failure(
          NotFoundError(message: "User is not authenticated"));
    }

    AppLogger.print("GetUserInteractor execute==================$id");
    final result = await _userRepository.getUserByAccountId(id);

    // NotFoundErrorの場合はデフォルトユーザーを返す
    return result.when(
      success: (user) => Result.success(user),
      failure: (error) {
        AppLogger.print("GetUserInteractor error========${error.message}");
        return Result.failure(error);
      },
    );
  }
}
