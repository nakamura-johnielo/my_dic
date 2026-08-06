import 'package:my_dic/app/session/current_session.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';

class UpdateUserInteractor implements IUpdateUserUseCase {
  final IUserRepository _userRepository;
  final CurrentSession _currentSession;

  UpdateUserInteractor(this._userRepository, this._currentSession);

  @override
  Future<Result<void>> execute(AppUser user) async {
    final accountId = _currentSession.accountIdOrNull;
    return await _userRepository.updateUser(user, accountId);
  }
}
