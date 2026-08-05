import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_ensure_user_exists_use_case.dart';

class EnsureUserExistsInteractor implements IEnsureUserExistsUseCase {
  final IUserRepository _userRepository;

  EnsureUserExistsInteractor(this._userRepository);

  @override
  Future<Result<AppUser>> execute(String id, {String? email}) =>
      _userRepository.ensureUserProfile(accountId: id, email: email);
}
