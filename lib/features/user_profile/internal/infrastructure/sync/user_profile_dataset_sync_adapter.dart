import 'package:my_dic/features/sync/port/dataset_sync_adapter.dart';
import 'package:my_dic/features/sync/port/model/remote_mutation.dart';
import 'package:my_dic/features/sync/port/model/sync_cursor.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/port/user_dto.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/i_user_remote_data_source.dart';

/// UserProfile's singleton-document mapping; durable sync policy lives in Sync runtime.
final class UserProfileDatasetSyncAdapter implements DatasetSyncAdapter {
  UserProfileDatasetSyncAdapter(
      {required IUserProfileLocalDataSource local,
      required IUserRemoteDataSource remote})
      : _local = local,
        _remote = remote;
  final IUserProfileLocalDataSource _local;
  final IUserRemoteDataSource _remote;
  @override
  SyncDataset get dataset => SyncDataset.userProfile;
  @override
  Future<RemoteMutationAck> push(RemoteMutationRequest request) =>
      _remote.patchUser(request);
  @override
  Future<List<DatasetSyncRecord>> pull(
      String accountId, SyncCursor? cursor) async {
    final user = await _remote.getUserById(accountId);
    if (user?.updatedAt == null) return const [];
    final candidate = _record(user!);
    return cursor == null || _cursor(candidate).compareTo(cursor) > 0
        ? [candidate]
        : const [];
  }

  @override
  Future<T> transaction<T>(Future<T> Function() action) =>
      _local.runInTransaction(action);
  @override
  Future<bool> acknowledge(
          {required SyncMutation mutation,
          required int leasedLocalRevision,
          required String accountId,
          required RemoteMutationAck acknowledgement}) =>
      _local.acknowledgeRemoteMutation(
          accountId: accountId,
          localRevision: leasedLocalRevision,
          remoteRevision: acknowledgement.remoteRevision.toString(),
          lastMutationId: acknowledgement.lastMutationId);
  @override
  Future<void> applyRemote(DatasetSyncRecord record,
      {required String accountId, required Set<String> skippedFields}) {
    final user = record.payload as UserDTO;
    return _local.applyRemoteFields(accountId,
        username: skippedFields.contains('username') ? null : user.userName,
        remoteRevision: record.remoteRevision.toString(),
        lastMutationId: record.lastMutationId);
  }

  DatasetSyncRecord _record(UserDTO user) => DatasetSyncRecord(
      entityId: user.userId,
      updatedAt: user.updatedAt!,
      remoteRevision: user.remoteRevision,
      lastMutationId: user.lastMutationId,
      payload: user);
  SyncCursor _cursor(DatasetSyncRecord record) => SyncCursor(
      seconds: record.updatedAt.millisecondsSinceEpoch ~/ 1000,
      nanoseconds: (record.updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
      documentId: record.entityId);
}
