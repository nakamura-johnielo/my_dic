import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';

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
