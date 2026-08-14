import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_dto.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/firebase/user_profile_remote_data_source.dart';

/// UserProfile's singleton-document mapping; durable sync policy lives in Sync runtime.
final class UserProfileDatasetSyncService implements DatasetSyncGateway {
  UserProfileDatasetSyncService(
      {required UserProfileLocalDataSource local,
      required UserProfileRemoteDataSource remote})
      : _local = local,
        _remote = remote;
  final UserProfileLocalDataSource _local;
  final UserProfileRemoteDataSource _remote;
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
  Future<void> _applyRemote(UserProfileRemoteDto user,
      {required String accountId, required Set<String> skippedFields}) {
    return _local.applyRemoteFields(accountId,
        username: skippedFields.contains('username') ? null : user.userName,
        remoteRevision: user.remoteRevision.toString(),
        lastMutationId: user.lastMutationId);
  }

  DatasetSyncRecord _record(UserProfileRemoteDto user) => DatasetSyncRecord(
      entityId: user.userId,
      updatedAt: user.updatedAt!,
      remoteRevision: user.remoteRevision,
      lastMutationId: user.lastMutationId,
      applyRemote: ({required accountId, required skippedFields}) =>
          _applyRemote(user,
              accountId: accountId, skippedFields: skippedFields));
  SyncCursor _cursor(DatasetSyncRecord record) => SyncCursor(
      seconds: record.updatedAt.millisecondsSinceEpoch ~/ 1000,
      nanoseconds: (record.updatedAt.microsecondsSinceEpoch % 1000000) * 1000,
      documentId: record.entityId);
}
