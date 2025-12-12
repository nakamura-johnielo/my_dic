import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

class UpdateUserInteractor {
  final IUserRepository _userRepository;

  UpdateUserInteractor(this._userRepository);

  Future<void> execute(AppUser user) async {
    await _userRepository.updateUser(user);
  }
}
