import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/_Business_Rule/_Domain/Repository_I/i_user_repository.dart';

class GetUserInteractor {
  final IUserRepository _userRepository;

  GetUserInteractor(this._userRepository);

  Future<AppUser> execute(String id) async {
    final user = await _userRepository.getUserById(id);
    if (user == null) {
      return AppUser(id: id);
    }
    return user;
  }
}

class UpdateUserInteractor {
  final IUserRepository _userRepository;

  UpdateUserInteractor(this._userRepository);

  Future<void> execute(AppUser user) async {
    await _userRepository.updateUser(user);
  }
}
