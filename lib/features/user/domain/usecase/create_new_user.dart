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
  Future<Result<AppUser>> execute(String accountId) async {
    // if (user.accountId.isEmpty) {
    //   return Result.failure(
    //       UnauthorizedError(message: "User ID cannot be empty. Must Login"));
    // }

    final res = await _userRepository.getThisDeviceId();

    //すでにDeviceidが存在する場合はエラーを返す
    return res.when(success: (id) {
      return Result.failure(AlreadyExistsError(
          message: "User already exists with the device ID $id"));
    }, failure: (failure) async {
      final uuid = MyUUID.generate();
      final newUser = AppUser(accountId: accountId, deviceId: uuid);
      final res = await _userRepository.createNewUser(newUser);
      return res.map((_) => newUser);
    });
  }
}
