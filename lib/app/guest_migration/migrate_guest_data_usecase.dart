import 'package:my_dic/features/my_word/port/my_word.dart';
import 'package:uuid/uuid.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/sync/port/outbox_writer.dart';
import 'package:my_dic/features/sync/port/session_fence.dart';
import 'package:my_dic/features/user_profile/port/guest_migration.dart';
import 'package:my_dic/features/word_status/port/guest_migration.dart';

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
    required IWordStatusGuestMigration wordStatus,
    required MyWordGuestMigrationPort myWord,
    required UserProfileGuestMigrationPort userProfile,
    required IOutboxWriter outboxWriter,
    required ISessionFence sessionFence,
    Uuid? uuid,
    DateTime Function()? clock,
  })  : _database = database,
        _wordStatus = wordStatus,
        _myWord = myWord,
        _userProfile = userProfile,
        _outboxWriter = outboxWriter,
        _sessionFence = sessionFence,
        _uuid = uuid ?? const Uuid(),
        _clock = clock ?? DateTime.now;

  final DatabaseProvider _database;
  final IWordStatusGuestMigration _wordStatus;
  final MyWordGuestMigrationPort _myWord;
  final UserProfileGuestMigrationPort _userProfile;
  final IOutboxWriter _outboxWriter;
  final ISessionFence _sessionFence;
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
      await _myWord.migrateGuestRows(
        accountId: accountId,
        migrationId: migrationId,
        clock: _clock,
      );
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

  /// Imports the only editable profile field. An account profile takes
  /// precedence when it already has a username; otherwise the guest value is
  /// retained. The guest row is removed in the same transaction as its
  /// outbox mutation, making retries safe after a successful import.
  Future<void> _migrateUserProfile(String accountId, String migrationId) async {
    await _userProfile.migrateGuestProfile(
      accountId: accountId,
      migrationId: migrationId,
      outboxWriter: _outboxWriter,
      clock: _clock,
    );
  }
}

class GuestMigrationSessionChanged implements Exception {
  const GuestMigrationSessionChanged();

  @override
  String toString() => 'Guest migration session changed';
}
