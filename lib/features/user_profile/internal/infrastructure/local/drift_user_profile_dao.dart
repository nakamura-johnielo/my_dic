import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/sync/user_profiles.dart';
part '../../../../../__generated/features/user_profile/internal/infrastructure/local/drift_user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<DatabaseProvider>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.database);

  Future<UserProfile?> getProfile(String accountId) {
    return (select(userProfiles)
          ..where((tbl) => tbl.accountId.equals(accountId)))
        .getSingleOrNull();
  }

  Stream<UserProfile?> watchProfile(String accountId) {
    return (select(userProfiles)
          ..where((tbl) => tbl.accountId.equals(accountId)))
        .watchSingleOrNull();
  }

  Future<void> deleteProfile(String accountId) async {
    await (delete(userProfiles)
          ..where((tbl) => tbl.accountId.equals(accountId)))
        .go();
  }

  /// プロフィール JSON ペイロードから編集可能な `username` フィールドを読み取ります。
  /// アカウントにローカルプロフィール行がまだない場合は `null` を返します。
  Future<String?> getUsername(String accountId) async {
    final row = await getProfile(accountId);
    if (row == null) return null;
    final payload = Map<String, Object?>.from(jsonDecode(row.payload) as Map);
    final username = payload['username'];
    return username is String ? username : null;
  }

  /// [fields] を [accountId] の既存 JSON `payload` にマージし、`local_revision` を
  /// 1 増やします。行がまだない場合は作成します。マージ後に永続化された行を返します。
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

  /// 呼び出し元がプロフィール行への書き込みとアウトボックス変更を原子的に組み合わせられるよう、
  /// 単一の Drift トランザクション内で [action] を実行します。
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    return transaction(action);
  }

  /// 後続のローカル書き込みがリースしたリビジョンを置き換えていない場合のみ、
  /// リモートトランザクションの確認応答を永続化します。
  Future<bool> acknowledgeRemoteMutation({
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(userProfiles)
          ..where((t) =>
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(UserProfilesCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
  }

  /// `local_revision` を増やしたりアウトボックス変更を追加したりせず、取得したリモート
  /// スナップショットを適用します。フィールドごとの `null` は「変更しない」を意味します。
  Future<void> applyRemoteFields(
    String accountId, {
    String? username,
    String? remoteRevision,
    String? lastMutationId,
  }) async {
    final existing = await getProfile(accountId);
    final currentPayload = existing == null
        ? <String, Object?>{}
        : Map<String, Object?>.from(jsonDecode(existing.payload) as Map);
    final mergedPayload = username == null
        ? currentPayload
        : {...currentPayload, 'username': username};

    await into(userProfiles).insertOnConflictUpdate(
      UserProfilesCompanion(
        accountId: Value(accountId),
        payload: Value(jsonEncode(mergedPayload)),
        localRevision: Value(existing?.localRevision ?? 0),
        remoteRevision: remoteRevision != null
            ? Value(remoteRevision)
            : Value(existing?.remoteRevision),
        lastMutationId: lastMutationId != null
            ? Value(lastMutationId)
            : Value(existing?.lastMutationId),
      ),
    );
  }
}
