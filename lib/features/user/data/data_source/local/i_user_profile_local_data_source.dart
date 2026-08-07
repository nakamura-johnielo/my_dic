import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract class IUserProfileLocalDataSource {
  Future<db.UserProfile?> getProfile(String accountId);

  /// Emits the account-scoped local profile whenever Drift persists a change.
  Stream<db.UserProfile?> watchProfile(String accountId);

  Future<void> deleteProfile(String accountId);

  /// Reads the editable `username` field out of the profile JSON payload,
  /// or `null` if the account has no local profile row yet.
  Future<String?> getUsername(String accountId);

  /// Merges [fields] into the existing editable profile JSON payload and
  /// bumps `local_revision` by 1, creating the row if it does not exist yet.
  Future<db.UserProfile> upsertProfileFields(
      String accountId, Map<String, Object?> fields);

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(String accountId, {String? username});

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a profile row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
