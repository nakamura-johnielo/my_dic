import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/utils/uuid.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/domain/usecase/i_create_new_user_use_case.dart';

class CreateNewUserInteractor implements ICreateNewUserUseCase {
  final IUserRepository _userRepository;

  CreateNewUserInteractor(this._userRepository);

  @override
   Future<Result<void>> execute(AppUser user) async {
    if (user.accountId.isEmpty ) {
      return Result.failure(UnauthorizedError(message: "User ID cannot be empty. Must Login"));
    }

    final uuid = MyUUID.generate();
    final newUser = user.copyWith(deviceId: uuid);
    await _userRepository.updateUser(newUser);
    return Result.success(null);
  }
}
