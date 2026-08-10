import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/user_profile/internal/infrastructure/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/user_profile/port/guest_migration.dart';

final class UserProfileGuestMigrationAdapter
    implements UserProfileGuestMigrationPort {
  UserProfileGuestMigrationAdapter(this._local);

  final IUserProfileLocalDataSource _local;

  @override
  Future<bool> hasGuestProfile() async =>
      await _local.getProfile(guestAccountScope) != null;

  @override
  Future<void> migrateGuestProfile({
    required String accountId,
    required String migrationId,
    required OutboxWriter outboxWriter,
    required DateTime Function() clock,
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
      await outboxWriter.enqueue(SyncMutation(
        mutationId: '$migrationId:${SyncDataset.userProfile.stableId}:$accountId',
        accountId: accountId,
        dataset: SyncDataset.userProfile,
        entityId: accountId,
        operation: SyncMutationOperation.upsert,
        payload: {'username': guestUsername},
        fieldMask: const ['username'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: clock().toUtc(),
      ));
    }
    await _local.deleteProfile(guestAccountScope);
  }
}
