import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/sync/user_profiles.dart';
part '../../../../../__generated/features/user/data/data_source/local/drift_user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<DatabaseProvider>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.database);

  Future<UserProfile?> getProfile(String accountId) {
    return (select(userProfiles)
          ..where((tbl) => tbl.accountId.equals(accountId)))
        .getSingleOrNull();
  }

  /// Reads the editable `username` field out of the profile JSON payload,
  /// or `null` if the account has no local profile row yet.
  Future<String?> getUsername(String accountId) async {
    final row = await getProfile(accountId);
    if (row == null) return null;
    final payload = Map<String, Object?>.from(jsonDecode(row.payload) as Map);
    final username = payload['username'];
    return username is String ? username : null;
  }

  /// Merges [fields] into the existing JSON `payload` for [accountId] and
  /// bumps `local_revision` by 1, creating the row if it does not exist yet.
  /// Returns the row as persisted after the merge.
  Future<UserProfile> upsertProfileFields(
      String accountId, Map<String, Object?> fields) async {
    final existing = await getProfile(accountId);
    final currentPayload = existing == null
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(existing.payload) as Map);
    final mergedPayload = {...currentPayload, ...fields};
    final nextRevision = (existing?.localRevision ?? 0) + 1;

    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion(
        accountId: Value(accountId),
        payload: Value(jsonEncode(mergedPayload)),
        localRevision: Value(nextRevision),
      ),
    );

    return UserProfile(
      accountId: accountId,
      payload: jsonEncode(mergedPayload),
      localRevision: nextRevision,
      remoteRevision: existing?.remoteRevision,
      deletedAt: existing?.deletedAt,
      lastMutationId: existing?.lastMutationId,
    );
  }

  /// Runs [action] within a single Drift transaction so callers can combine
  /// a profile row write with an outbox mutation atomically.
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    return transaction(action);
  }

  /// Applies a pulled remote snapshot without bumping `local_revision` or
  /// enqueueing an outbox mutation. `null` per field means "leave untouched".
  Future<void> applyRemoteFields(
    String accountId, {
    String? username,
  }) async {
    if (username == null) return;
    final existing = await getProfile(accountId);
    final currentPayload = existing == null
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(existing.payload) as Map);
    final mergedPayload = {...currentPayload, 'username': username};

    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion(
        accountId: Value(accountId),
        payload: Value(jsonEncode(mergedPayload)),
        localRevision: Value(existing?.localRevision ?? 0),
      ),
    );
  }
}
