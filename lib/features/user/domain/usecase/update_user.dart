import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';

class UpdateUserInteractor implements IUpdateUserUseCase {
  final IUserRepository _userRepository;

  UpdateUserInteractor(this._userRepository);

  @override
  Future<Result<void>> execute(AppUser user) async {
    return await _userRepository.updateUser(user);
  }
}
