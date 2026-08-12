import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/internal/infrastructure/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/my_word/port/guest_migration.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';

/// Drift-backed migration of the MyWord aggregate.
///
/// A same-ID MyWord collision preserves the account row and leaves its guest
/// word/status pair untouched. Status collisions for a successfully moved word
/// are merged with true winning for every flag.
final class MyWordGuestMigrationAdapter implements MyWordGuestMigrationPort {
  const MyWordGuestMigrationAdapter(
    this._myWord,
    this._myWordStatus,
    this._outboxWriter,
  );

  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;
  final IOutboxWriter _outboxWriter;

  @override
  Future<MyWordGuestRowCounts> countGuestRows() async {
    final words = await _myWord.getAllByAccountId(guestAccountScope);
    final statuses = await _myWordStatus.getAllByAccountId(guestAccountScope);
    return MyWordGuestRowCounts(words: words.length, statuses: statuses.length);
  }

  @override
  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  }) async {
    final guestWords = await _myWord.getAllByAccountId(guestAccountScope);
    for (final guestWord in guestWords) {
      final migrated = await _myWord.reassignAccountId(
        guestWord.myWordId,
        guestAccountScope,
        accountId,
      );
      if (migrated == null) continue;

      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _mutationId(
          migrationId,
          SyncDataset.myWords,
          migrated.myWordId,
        ),
        accountId: accountId,
        dataset: SyncDataset.myWords,
        entityId: migrated.myWordId,
        operation: SyncMutationOperation.upsert,
        payload: {'word': migrated.word, 'contents': migrated.contents},
        fieldMask: const ['word', 'contents'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: clock().toUtc(),
      ));
    }

    final guestStatuses =
        await _myWordStatus.getAllByAccountId(guestAccountScope);
    final editAt = clock().toUtc().toIso8601String();
    for (final guestStatus in guestStatuses) {
      // A word that remains in the guest scope collided at the target. Keep
      // this status with it to avoid splitting the aggregate pair.
      if (await _myWord.getMyWordById(
              guestStatus.myWordId, guestAccountScope) !=
          null) {
        continue;
      }
      if (await _myWord.getMyWordById(guestStatus.myWordId, accountId) ==
          null) {
        continue;
      }

      final accountStatus = await _myWordStatus.getWordStatus(
        guestStatus.myWordId,
        accountId,
      );
      final migrated = await _myWordStatus.applyStatusPatch(
        guestStatus.myWordId,
        guestStatus.isLearned == 1 || accountStatus?.isLearned == 1 ? 1 : 0,
        guestStatus.isBookmarked == 1 || accountStatus?.isBookmarked == 1
            ? 1
            : 0,
        guestStatus.hasNote == 1 || accountStatus?.hasNote == 1 ? 1 : 0,
        editAt,
        accountId,
      );
      await _myWordStatus.deleteRow(guestStatus.myWordId, guestAccountScope);
      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _mutationId(
          migrationId,
          SyncDataset.myWordStatus,
          migrated.myWordId,
        ),
        accountId: accountId,
        dataset: SyncDataset.myWordStatus,
        entityId: migrated.myWordId,
        operation: SyncMutationOperation.upsert,
        payload: {
          'isLearned': migrated.isLearned == 1,
          'isBookmarked': migrated.isBookmarked == 1,
          'hasNote': migrated.hasNote == 1,
        },
        fieldMask: const ['isLearned', 'isBookmarked', 'hasNote'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: DateTime.parse(editAt).toUtc(),
      ));
    }
  }

  String _mutationId(
    String migrationId,
    SyncDataset dataset,
    String entityId,
  ) =>
      '$migrationId:${dataset.stableId}:$entityId';
}
