import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/features/sync/port/sync_dataset.dart';
import 'package:my_dic/features/sync/port/model/sync_mutation.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/word_status/port/guest_migration.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/esp_jpn/drift/esp_jpn_word_status_local_data_source.dart';
import 'package:my_dic/features/word_status/internal/infrastructure/jpn_esp/drift/jpn_esp_word_status_local_data_source.dart';

/// Drift-backed implementation of the WordStatus part of guest migration.
///
/// This deliberately does not start a transaction: its caller combines this
/// work with MyWord, MyWordStatus, and UserProfile in one database fence.
class DriftWordStatusGuestMigration implements IWordStatusGuestMigration {
  DriftWordStatusGuestMigration({
    required EspJpnWordStatusLocalDataSource espJpn,
    required JpnEspWordStatusLocalDataSource jpnEsp,
    required IOutboxWriter outboxWriter,
  })  : _espJpn = espJpn,
        _jpnEsp = jpnEsp,
        _outboxWriter = outboxWriter;

  final EspJpnWordStatusLocalDataSource _espJpn;
  final JpnEspWordStatusLocalDataSource _jpnEsp;
  final IOutboxWriter _outboxWriter;

  @override
  Future<WordStatusGuestRowCounts> countGuestRows() async {
    final espJpn = await _espJpn.getWordStatusAfter(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      guestAccountScope,
    );
    final jpnEsp = await _jpnEsp.getWordStatusAfter(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      guestAccountScope,
    );
    return WordStatusGuestRowCounts(
        espJpn: espJpn.length, jpnEsp: jpnEsp.length);
  }

  @override
  Future<void> migrateGuestRows({
    required String accountId,
    required String migrationId,
    required DateTime Function() clock,
  }) async {
    await _migrateEspJpn(accountId, migrationId, clock);
    await _migrateJpnEsp(accountId, migrationId, clock);
  }

  Future<void> _migrateEspJpn(
    String accountId,
    String migrationId,
    DateTime Function() clock,
  ) async {
    final guestRows = await _espJpn.getWordStatusAfter(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      guestAccountScope,
    );
    for (final guestRow in guestRows) {
      final accountRow =
          await _espJpn.getWordStatusById(guestRow.wordId, accountId);
      final editedAt = clock();
      final isLearned = guestRow.isLearned == 1 || accountRow?.isLearned == 1;
      final isBookmarked =
          guestRow.isBookmarked == 1 || accountRow?.isBookmarked == 1;
      final hasNote = guestRow.hasNote == 1 || accountRow?.hasNote == 1;
      final updated = await _espJpn.updateWordStatus(
        guestRow.wordId,
        isLearned,
        isBookmarked,
        hasNote,
        editedAt.toIso8601String(),
        accountId,
      );
      await _espJpn.deleteRow(guestRow.wordId, guestAccountScope);
      await _enqueuePatch(
        migrationId: migrationId,
        dataset: SyncDataset.espJpnWordStatus,
        wordId: guestRow.wordId,
        accountId: accountId,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote,
        localRevision: updated.localRevision,
        clientUpdatedAt: editedAt.toUtc(),
      );
    }
  }

  Future<void> _migrateJpnEsp(
    String accountId,
    String migrationId,
    DateTime Function() clock,
  ) async {
    final guestRows = await _jpnEsp.getWordStatusAfter(
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      guestAccountScope,
    );
    for (final guestRow in guestRows) {
      final accountRow =
          await _jpnEsp.getWordStatusById(guestRow.wordId, accountId);
      final editedAt = clock();
      final isLearned = guestRow.isLearned == 1 || accountRow?.isLearned == 1;
      final isBookmarked =
          guestRow.isBookmarked == 1 || accountRow?.isBookmarked == 1;
      final hasNote = guestRow.hasNote == 1 || accountRow?.hasNote == 1;
      final updated = await _jpnEsp.updateWordStatus(
        guestRow.wordId,
        isLearned,
        isBookmarked,
        hasNote,
        editedAt.toIso8601String(),
        accountId,
      );
      await _jpnEsp.deleteRow(guestRow.wordId, guestAccountScope);
      await _enqueuePatch(
        migrationId: migrationId,
        dataset: SyncDataset.jpnEspWordStatus,
        wordId: guestRow.wordId,
        accountId: accountId,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote,
        localRevision: updated.localRevision,
        clientUpdatedAt: editedAt.toUtc(),
      );
    }
  }

  Future<void> _enqueuePatch({
    required String migrationId,
    required SyncDataset dataset,
    required int wordId,
    required String accountId,
    required bool isLearned,
    required bool isBookmarked,
    required bool hasNote,
    required int localRevision,
    required DateTime clientUpdatedAt,
  }) {
    final entityId = wordId.toString();
    return _outboxWriter.enqueue(SyncMutation(
      mutationId: '$migrationId:${dataset.stableId}:$entityId',
      accountId: accountId,
      dataset: dataset,
      entityId: entityId,
      operation: SyncMutationOperation.patch,
      payload: {
        'isLearned': isLearned,
        'isBookmarked': isBookmarked,
        'hasNote': hasNote,
      },
      fieldMask: const ['isLearned', 'isBookmarked', 'hasNote'],
      localRevision: localRevision,
      clientUpdatedAt: clientUpdatedAt,
    ));
  }
}
