import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract interface class UserProfileLocalDataSource {
  Future<db.UserProfile?> getProfile(String accountId);

  /// Drift が変更を永続化するたびに、アカウントスコープのローカルプロフィールを発行します。
  Stream<db.UserProfile?> watchProfile(String accountId);

  Future<void> deleteProfile(String accountId);

  /// プロフィール JSON ペイロードから編集可能な `username` フィールドを読み取ります。
  /// アカウントにローカルプロフィール行がまだない場合は `null` を返します。
  Future<String?> getUsername(String accountId);

  /// [fields] を既存の編集可能なプロフィール JSON ペイロードにマージし、`local_revision`
  /// を 1 増やします。行がまだない場合は作成します。
  Future<db.UserProfile> upsertProfileFields(
      String accountId, Map<String, Object?> fields);

  /// `local_revision` を増やしたりアウトボックス変更を追加したりせず、取得したリモート
  /// スナップショットを適用します。フィールドごとの `null` は「変更しない」を意味します。
  Future<void> applyRemoteFields(String accountId,
      {String? username, String? remoteRevision, String? lastMutationId});

  /// 呼び出し元がプロフィール行への書き込みとアウトボックス変更を原子的に組み合わせられるよう、
  /// 単一の Drift トランザクション内で [action] を実行します。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// ローカルプロフィールにリモート変更用にリースされたリビジョンがまだある場合のみ、
  /// サーバーメタデータを保存します。
  Future<bool> acknowledgeRemoteMutation({
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });
}
