import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/enums/sync_dataset.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_local_data_source.dart';
import 'package:my_dic/features/my_word/data/data_source/local/i_my_word_status_local_data_source.dart';
import 'package:my_dic/features/sync/application/model/sync_mutation.dart';
import 'package:my_dic/features/sync/application/port/outbox_writer.dart';
import 'package:my_dic/features/sync/application/port/session_fence.dart';
import 'package:my_dic/features/user/data/data_source/local/i_user_profile_local_data_source.dart';
import 'package:my_dic/features/word_status/application/port/word_status_guest_migration.dart';

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
/// Idempotency: every approved run creates one migration ID, shared by its
/// outbox mutations. A successful transaction leaves no guest-scoped rows,
/// so a later run is a no-op; a failed transaction rolls back both rows and
/// queued mutations together.
class MigrateGuestDataUseCase {
  MigrateGuestDataUseCase({
    required DatabaseProvider database,
    required WordStatusGuestMigration wordStatus,
    required IMyWordLocalDataSource myWord,
    required IMyWordStatusLocalDataSource myWordStatus,
    required IUserProfileLocalDataSource userProfile,
    required OutboxWriter outboxWriter,
    required SessionFence sessionFence,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _database = database,
        _wordStatus = wordStatus,
        _myWord = myWord,
        _myWordStatus = myWordStatus,
        _userProfile = userProfile,
        _outboxWriter = outboxWriter,
        _sessionFence = sessionFence,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final DatabaseProvider _database;
  final WordStatusGuestMigration _wordStatus;
  final IMyWordLocalDataSource _myWord;
  final IMyWordStatusLocalDataSource _myWordStatus;
  final IUserProfileLocalDataSource _userProfile;
  final OutboxWriter _outboxWriter;
  final SessionFence _sessionFence;
  final Uuid _uuid;
  final DateTime Function() _clock;

  Future<void> execute(String accountId, int sessionEpoch) async {
    _ensureCurrent(accountId, sessionEpoch);
    final migrationId = _uuid.v4();
    await _database.transaction(() async {
      _ensureCurrent(accountId, sessionEpoch);
      await _wordStatus.migrateGuestRows(
        accountId: accountId,
        migrationId: migrationId,
        clock: _clock,
      );
      await _migrateMyWords(accountId, migrationId);
      await _migrateMyWordStatuses(accountId, migrationId);
      await _migrateUserProfile(accountId, migrationId);
      // Throwing here is intentional: Drift rolls back every migrated row and
      // outbox mutation if the user changed account while the work was in
      // progress.
      _ensureCurrent(accountId, sessionEpoch);
    });
  }

  void _ensureCurrent(String accountId, int sessionEpoch) {
    if (!_sessionFence.isCurrent(
      accountId: accountId,
      sessionEpoch: sessionEpoch,
    )) {
      throw const GuestMigrationSessionChanged();
    }
  }

  String _mutationId(
          String migrationId, SyncDataset dataset, String entityId) =>
      '$migrationId:${dataset.stableId}:$entityId';

  /// Imports the only editable profile field. An account profile takes
  /// precedence when it already has a username; otherwise the guest value is
  /// retained. The guest row is removed in the same transaction as its
  /// outbox mutation, making retries safe after a successful import.
  Future<void> _migrateUserProfile(String accountId, String migrationId) async {
    final guest = await _userProfile.getProfile(guestAccountScope);
    if (guest == null) return;

    final guestUsername = await _userProfile.getUsername(guestAccountScope);
    final accountUsername = await _userProfile.getUsername(accountId);
    if (accountUsername == null && guestUsername != null) {
      final migrated = await _userProfile.upsertProfileFields(
        accountId,
        {'username': guestUsername},
      );
      await _outboxWriter.enqueue(SyncMutation(
        // One migration ID scopes all rows imported during this approval.
        // The dataset/entity suffix keeps each outbox primary key unique.
        mutationId:
            _mutationId(migrationId, SyncDataset.userProfile, accountId),
        accountId: accountId,
        dataset: SyncDataset.userProfile,
        entityId: accountId,
        operation: SyncMutationOperation.upsert,
        payload: {'username': guestUsername},
        fieldMask: const ['username'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: _clock().toUtc(),
      ));
    }

    // There is no delete mutation: a guest scope has no remote account.
    // Removing this local source row is transactional with the account write.
    await _userProfile.deleteProfile(guestAccountScope);
  }

  Future<void> _migrateMyWords(String accountId, String migrationId) async {
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
        mutationId:
            _mutationId(migrationId, SyncDataset.myWords, migrated.myWordId),
        accountId: accountId,
        dataset: SyncDataset.myWords,
        entityId: migrated.myWordId,
        operation: SyncMutationOperation.upsert,
        payload: {'word': migrated.word, 'contents': migrated.contents},
        fieldMask: const ['word', 'contents'],
        localRevision: migrated.localRevision,
        clientUpdatedAt: _clock().toUtc(),
      ));
    }
  }

  Future<void> _migrateMyWordStatuses(
      String accountId, String migrationId) async {
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
        mutationId: _mutationId(
            migrationId, SyncDataset.myWordStatus, migrated.myWordId),
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
}

class GuestMigrationSessionChanged implements Exception {
  const GuestMigrationSessionChanged();

  @override
  String toString() => 'Guest migration session changed';
}
