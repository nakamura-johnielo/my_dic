import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

class EnsureUserExistsInteractor {
  final IUserRepository _userRepository;

  EnsureUserExistsInteractor(this._userRepository);

  Future<AppUser> execute(String id) async {
    final user = await _userRepository.getUserById(id);

    //ゆざー登録済みならそのまま返す
    if (user != null) {
      return user;
    }

    //未登録なら新規作成して返す
    final newUser = AppUser(id: id);
    await _userRepository.updateUser(newUser);
    return newUser;
  }
}
