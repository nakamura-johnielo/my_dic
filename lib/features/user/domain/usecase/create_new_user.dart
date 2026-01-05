import 'package:my_dic/core/shared/errors/app_error.dart';
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
  Future<Result<AppUser>> execute(AppUser appUser) async {
    // if (user.accountId.isEmpty) {
    //   return Result.failure(
    //       UnauthorizedError(message: "User ID cannot be empty. Must Login"));
    // }

    final res = await _userRepository.getThisDeviceId();
    //
    String deviceId = MyUUID.generate();

    res.when(
        success: (id) {
          deviceId = id;
        },
        failure: (failure) {});

    final existingUserRes = await _userRepository.getUserByAccountId(appUser.accountId);
    
    return existingUserRes.when(success: (user) {
      // すでに存在する場合はそれを返す
      return Result.success(user);
    }, failure: (error) async {
      // NotFoundError以外のエラーはそのまま返す
      if (error is UserNotFoundError) {
        final name= appUser.email==null ? null : _convertUserName(appUser.email!);
        final newUser = appUser.copyWith(deviceId: deviceId, username: name);
        final resUser = await _userRepository.createNewUser(newUser);

        return resUser.when(
            success: (_) => Result.success(newUser),
            failure: (failure) => Result.failure(failure));
      }
      return Result.failure(error);
    });
  }

  String _convertUserName(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) {
      return email;
    }
    return email.substring(0, atIndex);
  }
}
