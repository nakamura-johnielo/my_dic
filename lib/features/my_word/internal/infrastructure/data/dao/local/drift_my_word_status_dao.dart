import 'package:drift/drift.dart';
import 'package:my_dic/core/shared/consts/account_scope.dart';
import 'package:my_dic/core/shared/utils/logger.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/my_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../../../__generated/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_status_dao.g.dart';

@DriftAccessor(tables: [MyWordStatus])
class MyWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordStatusDaoMixin {
  MyWordStatusDao(super.database);
  static const legacyOwner = guestAccountScope;

  Future<void> updateStatus(
    final String myWordId,
    final int? isLearned,
    final int? isBookmarked,
    final int? hasNote,
    final String editAt,
  ) async {
    AppLogger.print("update");
    await (update(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) & t.accountId.equals(legacyOwner)))
        .write(
      MyWordStatusCompanion(
        isLearned: isLearned != null ? Value(isLearned) : Value.absent(),
        isBookmarked:
            isBookmarked != null ? Value(isBookmarked) : Value.absent(),
        hasNote: hasNote != null ? Value(hasNote) : Value.absent(),
        editAt: Value(editAt),
      ),
    );
  }

  Future<void> insertStatus(MyWordStatusTableData data) async {
    await into(myWordStatus).insert(data);
    AppLogger.print("insert");
  }

  Future<bool> exist(String id) async {
    final existingColum = await (select(myWordStatus)
          ..where(
              (t) => t.myWordId.equals(id) & t.accountId.equals(legacyOwner)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }

  Stream<MyWordStatusTableData?> watchWordStatus(
      String wordId, String accountId) {
    return (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .watchSingleOrNull()
        .distinct();
  }

  Future<MyWordStatusTableData?> getWordStatus(
      String wordId, String accountId) async {
    final data = await (select(myWordStatus)
          ..where((tbl) =>
              tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
        .getSingleOrNull();
    return data;
  }

  /// [accountId] の全行を返す。単一行ではなく完全な集合を必要とするゲストデータの
  /// 検出・移行で使用する。
  Future<List<MyWordStatusTableData>> getAllByAccountId(String accountId) {
    return (select(myWordStatus)..where((t) => t.accountId.equals(accountId)))
        .get();
  }

  /// ステータス行のアカウントスコープをその場で再割り当てする（例: ゲストからログイン済み
  /// アカウント）。対応するアウトボックス変更をキューに入れられるよう `local_revision` を増やす。
  /// [fromAccountId] に一致する行がないか [toAccountId] に行がすでにある場合は `null` を返す
  /// （呼び出し元でマージまたはスキップする）。
  Future<MyWordStatusTableData?> reassignAccountId(
      String myWordId, String fromAccountId, String toAccountId) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, fromAccountId);
      if (existing == null) return null;
      final conflict = await getWordStatus(myWordId, toAccountId);
      if (conflict != null) return null;
      await (update(myWordStatus)
            ..where((t) =>
                t.myWordId.equals(myWordId) &
                t.accountId.equals(fromAccountId)))
          .write(MyWordStatusCompanion(
        accountId: Value(toAccountId),
        localRevision: Value(existing.localRevision + 1),
      ));
      return getWordStatus(myWordId, toAccountId);
    });
  }

  Future<void> deleteRow(String myWordId, String accountId) async {
    await (delete(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
        .go();
  }

  /// 後続のローカル書き込みがリース済みリビジョンを置き換えていない場合にのみ、
  /// リモートトランザクションの確認応答を保存する。
  Future<bool> acknowledgeRemoteMutation({
    required String myWordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(myWordStatus)
          ..where((t) =>
              t.myWordId.equals(myWordId) &
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(MyWordStatusCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
  }

  /// ステータス行を upsert して `local_revision` を 1 増やす（新規行は 1 から開始）。呼び出し元は
  /// 同じトランザクションで対応するアウトボックス変更をキューに入れられる。フィールドごとの `null` は
  /// 更新時に「変更しない」を意味する。
  Future<MyWordStatusTableData> applyStatusPatch(
    String myWordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
    String accountId,
  ) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, accountId);
      final nextRevision = (existing?.localRevision ?? 0) + 1;
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: Value(nextRevision),
          ),
        );
      } else {
        await (update(myWordStatus)
              ..where((t) =>
                  t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
            .write(
          MyWordStatusCompanion(
            isLearned:
                isLearned != null ? Value(isLearned) : const Value.absent(),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked)
                : const Value.absent(),
            hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
            editAt: Value(editAt),
            localRevision: Value(nextRevision),
          ),
        );
      }
      final updated = await getWordStatus(myWordId, accountId);
      if (updated == null) {
        throw StateError('MyWordStatus was not persisted: $myWordId');
      }
      return updated;
    });
  }

  /// `local_revision` を増やしたりアウトボックスに触れたりせず、取得したリモートスナップショットを適用する。
  /// フィールドごとの `null` は「変更しない」を意味する（同期ハンドラーが送信中のローカル変更を持つ
  /// フィールドをスキップするために使用する）。
  Future<void> applyRemoteFields(
    String myWordId, {
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return transaction(() async {
      final existing = await getWordStatus(myWordId, accountId);
      if (existing == null) {
        await into(myWordStatus).insert(
          MyWordStatusCompanion.insert(
            myWordId: myWordId,
            isLearned: Value(isLearned ?? 0),
            isBookmarked: Value(isBookmarked ?? 0),
            hasNote: Value(hasNote ?? 0),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: const Value(0),
            remoteRevision: Value(remoteRevision),
            lastMutationId: Value(lastMutationId),
          ),
        );
        return;
      }
      await (update(myWordStatus)
            ..where((t) =>
                t.myWordId.equals(myWordId) & t.accountId.equals(accountId)))
          .write(
        MyWordStatusCompanion(
          isLearned:
              isLearned != null ? Value(isLearned) : const Value.absent(),
          isBookmarked:
              isBookmarked != null ? Value(isBookmarked) : const Value.absent(),
          hasNote: hasNote != null ? Value(hasNote) : const Value.absent(),
          editAt: Value(editAt),
          remoteRevision: remoteRevision != null
              ? Value(remoteRevision)
              : const Value.absent(),
          lastMutationId: lastMutationId != null
              ? Value(lastMutationId)
              : const Value.absent(),
        ),
      );
    });
  }

  /// [action] を単一の Drift トランザクションで実行し、呼び出し元がステータス行の書き込みと
  /// アウトボックス変更をアトミックに組み合わせられるようにする。
  Future<T> runInTransaction<T>(Future<T> Function() action) =>
      transaction(action);
}
