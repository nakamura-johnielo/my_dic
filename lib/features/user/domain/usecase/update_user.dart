import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/auth/domain/I_repository/i_auth_repository.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_update_user_use_case.dart';

class UpdateUserInteractor implements IUpdateUserUseCase {
  final IUserRepository _userRepository;
  final IAuthRepository _authRepository;

  UpdateUserInteractor(this._userRepository, this._authRepository);

  @override
  Future<Result<void>> execute(AppUser user) async {
    final authResult = await _authRepository.getCurrentAuth();
    String? accountId;
    authResult.when(
      success: (auth) {
        if (auth.isAuthenticated && auth.accountId.isNotEmpty) {
          accountId = auth.accountId;
        }
      },
      failure: (_) {},
    );
    return await _userRepository.updateUser(user, accountId);
  }
}
