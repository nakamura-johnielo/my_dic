import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/data/data_source/remote/user_profile_dao.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';

class FirebaseUserRepository implements IUserRepository {
  final UserDao _userProfileDao;
  FirebaseUserRepository(this._userProfileDao);

  @override
  Future<Result<AppUser>> getUserById(String id) async {
    try {
      final profileData = await _userProfileDao.getUser(id);
      if (profileData == null) {
        return Result.failure(NotFoundError(
          message: 'ユーザーが見つかりません',
        ));
      }
      final user = AppUser(
        id: id,
        email: profileData.email,
        username: profileData.userName,
        subscriptionStatus: profileData.subscriptionStatus,
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
      final userEntity = UserDTO(
        userId: user.id,
        email: user.email,
        userName: user.username,
        subscriptionStatus: user.subscriptionStatus,
        updatedAt: DateTime.now(),
      );
      await _userProfileDao.update(userEntity);
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
}
