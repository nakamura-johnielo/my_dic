import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/dataset_contract.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/port/composition_contract.dart';
import 'package:my_dic/features/user_profile/port/user_profile.dart';

final class UserProfileGuestMigrationService
    implements UserProfileGuestMigrationPort {
  UserProfileGuestMigrationService(
    this._local,
    this._outboxWriter,
    this._clock,
  );

  final UserProfileLocalDataSource _local;
  final OutboxWriter _outboxWriter;
  final UserProfileClock _clock;

  @override
  Future<bool> hasGuestProfile() async =>
      await _local.getProfile(guestAccountScope) != null;

  @override
  Future<void> migrateGuestProfile({
    required String accountId,
    required String migrationId,
  }) async {
    final guest = await _local.getProfile(guestAccountScope);
    if (guest == null) return;
    final guestUsername = await _local.getUsername(guestAccountScope);
    final accountUsername = await _local.getUsername(accountId);
    if (accountUsername == null && guestUsername != null) {
      final migrated = await _local.upsertProfileFields(
        accountId,
        {'username': guestUsername},
      );
      await _outboxWriter.enqueue(SyncMutation(
        mutationId:
            '$migrationId:${SyncDataset.userProfile.stableId}:$accountId',
        accountId: accountId,
        dataset: SyncDataset.userProfile,
        entityId: accountId,
        operation: SyncMutationOperation.upsert,
        payload: {'username': guestUsername},
        fieldMask: const ['username'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: _clock.now().toUtc(),
      ));
    }
    await _local.deleteProfile(guestAccountScope);
  }
}
