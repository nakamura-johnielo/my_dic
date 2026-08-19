import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart'
    as db;

abstract interface class IMyWordStatusLocalDataSource {
  Future<void> updateStatus(
    final String myWordId,
    final int? isLearned,
    final int? isBookmarked,
    final int? hasNote,
    final String editAt,
  );
  Future<void> insertStatus(db.MyWordStatusTableData data);
  Future<bool> existStatus(String id);
  Stream<db.MyWordStatusTableData?> watchWordStatus(
      String wordId, String accountId);
  Future<db.MyWordStatusTableData?> getWordStatus(
      String wordId, String accountId);

  /// ステータス行を upsert し、`local_revision` を 1 増やす。
  Future<db.MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
    String accountId,
  );

  /// `local_revision` を増やしたりアウトボックス変更をキューに入れたりせず、取得したリモート
  /// スナップショットを適用する。フィールドごとの `null` は「変更しない」を意味する。
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// [action] を単一の Drift トランザクション内で実行し、呼び出し元がステータス行の書き込みと
  /// アウトボックス変更をアトミックに組み合わせられるようにする。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// ローカル行がリモート変更用にリースされたリビジョンをまだ保持している場合にのみ、
  /// サーバーメタデータを保存する。
  Future<bool> acknowledgeRemoteMutation({
    required String myWordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// [accountId] の行をすべて返す。単一行ではなく完全な集合を必要とする、ゲストデータの
  /// 検出・移行で使用する。
  Future<List<db.MyWordStatusTableData>> getAllByAccountId(String accountId);

  /// ステータス行のアカウントスコープをその場で再割り当てする。[fromAccountId] に一致する行が
  /// ないか、[toAccountId] に行がすでに存在する場合は `null` を返す。
  Future<db.MyWordStatusTableData?> reassignAccountId(
      String myWordId, String fromAccountId, String toAccountId);

  /// ゲストデータ移行中に別のスコープへマージされた後、要求されたアカウントスコープの
  /// ステータス行を 1 行削除する。
  Future<void> deleteRow(String myWordId, String accountId);
}
