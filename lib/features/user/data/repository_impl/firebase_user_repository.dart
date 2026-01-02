import 'package:firebase_core/firebase_core.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/errors/unexpected_error.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/user/domain/entity/user.dart';
import 'package:my_dic/features/user/domain/i_repository/i_user_repository.dart';
import 'package:my_dic/features/user/data/data_source/remote/i_user_remote_data_source.dart';
import 'package:my_dic/features/user/data/dto/user_dto.dart';


class UserRepository implements IUserRepository {
  final IUserRemoteDataSource _dataSource;
  UserRepository(this._dataSource);

  @override
  Future<Result<AppUser>> getUserById(String id) async {
    try {
      final dto = await _dataSource.getUserById(id);
      if (dto == null) {
        return Result.failure(NotFoundError(
          message: 'ユーザーが見つかりません',
        ));
      }
      final user = AppUser(
        id: dto.userId,
        username: dto.userName,
        email: dto.email,
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
      final dto = UserDTO(
        userId: user.id,
        userName: user.username,
        email: user.email,
        createdAt:null ,
        updatedAt:null ,
      );
      await _dataSource.updateUser(dto);
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
