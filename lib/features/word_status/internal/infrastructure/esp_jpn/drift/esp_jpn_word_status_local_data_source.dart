import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/word_status/internal/domain/model/word_status_record.dart';

abstract class EspJpnWordStatusLocalDataSource {
  Future<WordStatusRecord?> getWordStatusRecordById(int id, String accountId);
  Future<List<WordStatusRecord>> getWordStatusRecordsByIds(
      Iterable<int> ids, String accountId);
  Stream<WordStatusRecord?> watchWordStatusRecordById(
      int id, String accountId);

  Future<EspJpnWordStatusTableData?> getWordStatusById(
      int id, String accountId);
  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime, String accountId);
  Future<EspJpnWordStatusTableData> updateWordStatus(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
    String accountId,
  );
  Stream<EspJpnWordStatusTableData?> watchWordStatusById(
      int id, String accountId);
  Stream<List<int>> watchChangedIds(DateTime datetime, String accountId);

  /// local_revision を増やしたりアウトボックス変更を追加したりせず、取得したリモート
  /// スナップショットを適用します。フィールドごとの `null` は「変更しない」を意味します。
  Future<void> applyRemoteFields(
    int wordId, {
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  });

  /// 呼び出し元がステータス行の書き込みとアウトボックス変更を原子的に組み合わせられるよう、
  /// 単一の Drift トランザクション内で [action] を実行します。
  Future<T> runInTransaction<T>(Future<T> Function() action);

  /// 送信したローカル編集がリースされたリビジョンである間だけ、サーバー確認済みリビジョンを
  /// 保存します。これにより古い送信が新しいローカル編集のメタデータを確認することを防ぎます。
  Future<bool> acknowledgeRemoteMutation({
    required int wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  });

  /// [accountId] にスコープされた [id] の行を 1 件削除します。マージ後のゲスト行を削除する
  /// ゲストからアカウントへの移行で使用します。
  Future<void> deleteRow(int id, String accountId);
}
