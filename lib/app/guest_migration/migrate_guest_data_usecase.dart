import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp_word_status/i_local_jpn_esp_word_status_data_source.dart';
import 'package:my_dic/core/infrastructure/datasource/word_status/i_local_word_status_data_source.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/consts/dates.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';

/// Moves every guest-scoped local row to a signed-in account, atomically.
///
/// Word status (esp_jpn/jpn_esp) entities are keyed by a shared dictionary
/// wordId, so a guest row and an existing account row for the same word can
/// legitimately both exist; their boolean fields are OR-merged (true wins)
/// and the row is written under the account scope, then the guest row is
/// removed. MyWord/MyWordStatus entities are keyed by a UUID generated at
/// creation time, so a same-id collision between a guest row and an account
/// row is not expected in practice; those rows are simply re-keyed in place,
/// and in the practically-impossible collision case the account's existing
/// row is kept and the guest row is left untouched (not migrated).
///
/// Idempotency: a successful run leaves no guest-scoped rows behind, so
/// re-running this for the same account is a no-op rather than needing a
/// separate migration-id ledger.
class MigrateGuestDataUseCase {
  MigrateGuestDataUseCase({
    required DatabaseProvider database,
    required ILocalWordStatusDataSource espJpnWordStatus,
    required ILocalJpnEspWordStatusDataSource jpnEspWordStatus,
    required IMyWordLocalDataSource myWord,
    required IMyWordStatusLocalDataSource myWordStatus,
    required OutboxWriter outboxWriter,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _database = database,
        _espJpnWordStatus = espJpnWordStatus,
        _jpnEspWordStatus = jpnEspWordStatus,
        _myWord = myWord,
        _myWordStatus = myWordStatus,
        _outboxWriter = outboxWriter,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final DatabaseProvider _database;
  final ILocalWordStatusDataSource _espJpnWordStatus;
  final ILocalJpnEspWordStatusDataSource _jpnEspWordStatus;
  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;
  final OutboxWriter _outboxWriter;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> execute(String accountId) async {
    await _database.transaction(() async {
      await _migrateEspJpnWordStatus(accountId);
      await _migrateJpnEspWordStatus(accountId);
      await _migrateMyWords(accountId);
      await _migrateMyWordStatuses(accountId);
    });
  }

  Future<void> _migrateEspJpnWordStatus(String accountId) async {
    final guestRows = await _espJpnWordStatus.getWordStatusAfter(
        MyDateTime.sentinel, guestAccountScope);
    final editAt = _clock().toIso8601String();
    for (final guestRow in guestRows) {
      final accountRow =
          await _espJpnWordStatus.getWordStatusById(guestRow.wordId, accountId);
      final isLearned = guestRow.isLearned == 1 || accountRow?.isLearned == 1;
      final isBookmarked =
          guestRow.isBookmarked == 1 || accountRow?.isBookmarked == 1;
      final hasNote = guestRow.hasNote == 1 || accountRow?.hasNote == 1;
      final updated = await _espJpnWordStatus.updateWordStatus(
        guestRow.wordId,
        isLearned,
        isBookmarked,
        hasNote,
        editAt,
        accountId,
      );
      await _espJpnWordStatus.deleteRow(guestRow.wordId, guestAccountScope);
      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _uuid.v4(),
        accountId: accountId,
        dataset: SyncDataset.espJpnWordStatus,
        entityId: guestRow.wordId.toString(),
        operation: SyncMutationOperation.patch,
        payload: {
          'isLearned': isLearned,
          'isBookmarked': isBookmarked,
          'hasNote': hasNote,
        },
        fieldMask: const ['isLearned', 'isBookmarked', 'hasNote'],
        localRevision: updated.localRevision,
      ));
    }
  }

  Future<void> _migrateJpnEspWordStatus(String accountId) async {
    final guestRows = await _jpnEspWordStatus.getWordStatusAfter(
        MyDateTime.sentinel, guestAccountScope);
    final editAt = _clock().toIso8601String();
    for (final guestRow in guestRows) {
      final accountRow =
          await _jpnEspWordStatus.getWordStatusById(guestRow.wordId, accountId);
      final isLearned = guestRow.isLearned == 1 || accountRow?.isLearned == 1;
      final isBookmarked =
          guestRow.isBookmarked == 1 || accountRow?.isBookmarked == 1;
      final hasNote = guestRow.hasNote == 1 || accountRow?.hasNote == 1;
      final updated = await _jpnEspWordStatus.updateWordStatus(
        guestRow.wordId,
        isLearned,
        isBookmarked,
        hasNote,
        editAt,
        accountId,
      );
      await _jpnEspWordStatus.deleteRow(guestRow.wordId, guestAccountScope);
      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _uuid.v4(),
        accountId: accountId,
        dataset: SyncDataset.jpnEspWordStatus,
        entityId: guestRow.wordId.toString(),
        operation: SyncMutationOperation.patch,
        payload: {
          'isLearned': isLearned,
          'isBookmarked': isBookmarked,
          'hasNote': hasNote,
        },
        fieldMask: const ['isLearned', 'isBookmarked', 'hasNote'],
        localRevision: updated.localRevision,
      ));
    }
  }

  Future<void> _migrateMyWords(String accountId) async {
    final guestRows = await _myWord.getAllByAccountId(guestAccountScope);
    for (final guestRow in guestRows) {
      final migrated = await _myWord.reassignAccountId(
          guestRow.myWordId, guestAccountScope, accountId);
      if (migrated == null) {
        // A same-id row already exists at the target account (practically
        // impossible for UUID-keyed entities); keep the account's row and
        // leave the guest row untouched rather than risk clobbering it.
        continue;
      }
      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _uuid.v4(),
        accountId: accountId,
        dataset: SyncDataset.myWords,
        entityId: migrated.myWordId,
        operation: SyncMutationOperation.upsert,
        payload: {'word': migrated.word, 'contents': migrated.contents},
        fieldMask: const ['word', 'contents'],
        localRevision: migrated.localRevision,
      ));
    }
  }

  Future<void> _migrateMyWordStatuses(String accountId) async {
    final guestRows = await _myWordStatus.getAllByAccountId(guestAccountScope);
    final editAt = _clock().toIso8601String();
    for (final guestRow in guestRows) {
      // A MyWord collision intentionally leaves the guest row untouched.
      // Keep its status there as well: otherwise the target account would get
      // a status for a different MyWord while the guest pair is split apart.
      final remainingGuestWord =
          await _myWord.getMyWordById(guestRow.myWordId, guestAccountScope);
      if (remainingGuestWord != null) {
        continue;
      }
      final targetWord =
          await _myWord.getMyWordById(guestRow.myWordId, accountId);
      if (targetWord == null) continue;

      final accountRow =
          await _myWordStatus.getWordStatus(guestRow.myWordId, accountId);
      final migrated = await _myWordStatus.applyStatusPatch(
        guestRow.myWordId,
        guestRow.isLearned == 1 || accountRow?.isLearned == 1 ? 1 : 0,
        guestRow.isBookmarked == 1 || accountRow?.isBookmarked == 1 ? 1 : 0,
        guestRow.hasNote == 1 || accountRow?.hasNote == 1 ? 1 : 0,
        editAt,
        accountId,
      );
      await _myWordStatus.deleteRow(guestRow.myWordId, guestAccountScope);
      await _outboxWriter.enqueue(SyncMutation(
        mutationId: _uuid.v4(),
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
      ));
    }
  }
}
