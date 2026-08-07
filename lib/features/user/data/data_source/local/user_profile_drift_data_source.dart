import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;
import 'package:my_dic/features/user/data/data_source/local/drift_user_profile_dao.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';

class UserProfileDriftDataSource implements IUserProfileLocalDataSource {
  final UserProfileDao _dao;

  UserProfileDriftDataSource(this._dao);

  @override
  Future<db.UserProfile?> getProfile(String accountId) =>
      _dao.getProfile(accountId);

  @override
  Future<String?> getUsername(String accountId) => _dao.getUsername(accountId);

  @override
  Future<db.UserProfile> upsertProfileFields(
          String accountId, Map<String, Object?> fields) =>
      _dao.upsertProfileFields(accountId, fields);

  @override
  Future<void> applyRemoteFields(String accountId, {String? username}) =>
      _dao.applyRemoteFields(accountId, username: username);

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      _dao.runInTransaction(action);
}
