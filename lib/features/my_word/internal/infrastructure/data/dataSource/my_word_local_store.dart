import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract interface class MyWordLocalDataSource {
  Future<db.MyWordTableData?> getMyWordById(String id, String accountId);

  Future<List<db.MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset, String accountId);

  Future<List<String>?> getIdsFilteredMyWordByPage(
      int size, int offset, String accountId);

  Stream<db.MyWordTableData?> streamMyWordById(String id, String accountId);

  /// `local_revision` を 1 から開始して、新しい MyWord 行を挿入する。
  Future<db.MyWordTableData> insertMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  });

  /// 既存の MyWord 行を更新し、`local_revision` を 1 増やす。
  /// 一致する行がない場合は `null` を返す。
  Future<db.MyWordTableData?> updateMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  });

  /// MyWord 行を物理削除せず、論理削除（トゥームストーン化）する。
  /// 未削除の一致行がない場合は `null` を返す。
  Future<db.MyWordTableData?> tombstoneMyWord(
      String wordId, String deletedAt, String accountId);

  /// `local_revision` を増やしたりアウトボックス変更をキューに入れたりせず、取得したリモート
  /// スナップショットを適用する。フィールドごとの `null` は「変更しない」を意味する。
  Future<void> applyRemoteFields(
    String wordId, {
    String? word,
    String? contents,
    String? deletedAt,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// [action] を単一の Drift トランザクション内で実行し、呼び出し元が MyWord 行の書き込みと
  /// アウトボックス変更をアトミックに組み合わせられるようにする。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// ローカル行がリモート変更用にリースされたリビジョンをまだ保持している場合にのみ、
  /// サーバーメタデータを保存する。
  Future<bool> acknowledgeRemoteMutation({
    required String wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// [accountId] の未削除行をすべて返す。ページではなく完全な集合を必要とする、ゲストデータの
  /// 検出・移行で使用する。
  Future<List<db.MyWordTableData>> getAllByAccountId(String accountId);

  /// 行のアカウントスコープをその場で再割り当てする。[fromAccountId] に一致する行がないか、
  /// [toAccountId] に行がすでに存在する場合は `null` を返す。
  Future<db.MyWordTableData?> reassignAccountId(
      String wordId, String fromAccountId, String toAccountId);
}
