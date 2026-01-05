import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/errors/app_error.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_local_data_source.dart';
import 'package:my_dic/features/user/data/dto/local_user_dto.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class UserRepository implements IUserRepository {
  final IUserRemoteDataSource _remote;
  final IUserLocalDataSource _local;
  UserRepository(this._remote, this._local);

  AppError? _handleIdError(AppUser user) {
    if (user.deviceId?.isEmpty ?? true) {
      return DeviceNotFoundError(
        message: 'device ID が生成されていません',
      );
    }
    if (user.accountId?.isEmpty ?? true) {
      return UnauthorizedError(
          message: "Account ID cannot be empty. Must Login");
    }
    return null;
  }

  @override
  Future<Result<AppUser>> getUserByAccountId(String id) async {
    try {
      print("reposiotry.getbyid");
      final deviceId = (await _local.getUser())?.deviceId;
      if (deviceId == null) {
        return Result.failure(DeviceNotFoundError(
          message: 'device ID が生成されていません',
        ));
      }
      print("deviceId=$deviceId");
      final dto = await _remote.getUserById(id);
      print("pass dto found==${dto?.userId}");
      if (dto == null) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!dto null");
        return Result.failure(UserNotFoundError(
          message: 'ユーザーが見つかりません',
        ));
      }
      print("dto found==${dto.userId}");
      final user = AppUser(
        accountId: dto.userId,
        username: dto.userName,
        email: dto.email,
        deviceId: deviceId,
      );
      return Result.success(user);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'ユーザー情報の取得に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'ユーザー情報の取得中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> updateUser(AppUser user) async {
    try {
      final error = _handleIdError(user);
      if (error != null) {
        return Result.failure(error);
      }

      final dto = UserDTO(
        userId: user.accountId,
        userName: user.username,
        email: user.email,
        createdAt: null,
        updatedAt: null,
      );
      await _remote.updateUser(dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'ユーザー情報の更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'ユーザー情報の更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<void>> createNewUser(AppUser user) async {
    try {
      final error = _handleIdError(user);
      if (error != null) {
        return Result.failure(error);
      }

      await _local.updateUser(
        LocalUserDTO(
          deviceId: user.deviceId!,
        ),
      );

      final dto = UserDTO(
        subscriptionStatus: user.subscriptionStatus ,
        userId: user.accountId,
        userName: user.username,
        email: user.email,
        createdAt: null,
        updatedAt: null,
      );
      await _remote.updateUser(dto);
      return const Result.success(null);
    } on FirebaseException catch (e, s) {
      return Result.failure(FirebaseError(
        message: 'ユーザー情報の更新に失敗しました: ${e.message}',
        code: e.code,
        originalError: e,
        stackTrace: s,
      ));
    } catch (e, s) {
      return Result.failure(UnexpectedError(
        message: 'ユーザー情報の更新中に予期しないエラーが発生しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }

  @override
  Future<Result<String>> getThisDeviceId() async {
    final localUser = await _local.getUser();

    if (localUser?.deviceId.isEmpty ?? true) {
      return Result.failure(DeviceNotFoundError(
        message: 'device ID が生成されていません',
      ));
    }
    return Result.success(localUser!.deviceId);
  }
}
