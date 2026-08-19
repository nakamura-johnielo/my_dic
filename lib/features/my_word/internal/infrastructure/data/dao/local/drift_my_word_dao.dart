import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/my_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/my_words.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../../../__generated/features/my_word/internal/infrastructure/data/data_source/local/drift_my_word_dao.g.dart';

/// アカウントスコープの MyWord・ステータスプロジェクションに対する、生の読み取り専用結果。
class MyWordItemRow {
  const MyWordItemRow({required this.word, required this.status});

  final MyWordTableData word;
  final MyWordStatusTableData? status;
}

@DriftAccessor(tables: [MyWords, MyWordStatus])
class MyWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordDaoMixin {
  MyWordDao(super.database);
  Future<MyWordTableData?> getMyWordById(String id, String accountId) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(accountId) &
              tbl.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<List<MyWordTableData>?> getFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    return (select(myWords)
          ..where((t) => t.accountId.equals(accountId) & t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm.desc(t.editAt),
          ])
          ..limit(size, offset: offset))
        .get();
  }

  Future<List<String>?> getIdsFilteredMyWordByPage(
      int size, int offset, String accountId) async {
    final query = selectOnly(myWords)
      ..addColumns([myWords.myWordId])
      ..where(myWords.accountId.equals(accountId) & myWords.deletedAt.isNull())
      ..orderBy([
        OrderingTerm.desc(myWords.editAt),
      ])
      ..limit(size, offset: offset);

    final rows = await query.get();
    return rows.map((row) => row.read(myWords.myWordId)!).toList();
  }

  /// [accountId] の未削除行をすべて返す。ページではなく完全な集合を必要とするゲストデータの
  /// 検出・移行で使用する。
  Future<List<MyWordTableData>> getAllByAccountId(String accountId) {
    return (select(myWords)
          ..where((t) => t.accountId.equals(accountId) & t.deletedAt.isNull()))
        .get();
  }

  /// 行のアカウントスコープをその場で再割り当てする（例: ゲストからログイン済みアカウント）。
  /// 対応するアウトボックス変更をキューに入れられるよう `local_revision` を増やす。[fromAccountId] に
  /// 一致する行がないか [toAccountId] に行がすでにある場合は `null` を返す（呼び出し元でマージまたはスキップする）。
  Future<MyWordTableData?> reassignAccountId(
      String wordId, String fromAccountId, String toAccountId) {
    return transaction(() async {
      final existing = await getMyWordById(wordId, fromAccountId);
      if (existing == null) return null;
      final conflict = await getMyWordById(wordId, toAccountId);
      if (conflict != null) return null;
      await (update(myWords)
            ..where((t) =>
                t.myWordId.equals(wordId) & t.accountId.equals(fromAccountId)))
          .write(MyWordsCompanion(
        accountId: Value(toAccountId),
        localRevision: Value(existing.localRevision + 1),
      ));
      return getMyWordById(wordId, toAccountId);
    });
  }

  /// `local_revision` を 1 から開始して新しい MyWord 行を挿入する。呼び出し元は同じトランザクションで
  /// 対応するアウトボックス変更をキューに入れられる。
  Future<MyWordTableData> insertMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  }) async {
    final data = MyWordTableData(
      myWordId: id,
      word: word,
      contents: contents,
      editAt: editAt,
      accountId: accountId,
      localRevision: 1,
    );
    await into(myWords).insert(data);
    return data;
  }

  /// 既存の MyWord 行を更新して `local_revision` を 1 増やす。呼び出し元は同じトランザクションで
  /// 対応するアウトボックス変更をキューに入れられる。一致する行がない場合は `null` を返す。
  Future<MyWordTableData?> updateMyWordWithRevision({
    required String id,
    required String word,
    required String contents,
    required String editAt,
    required String accountId,
  }) {
    return transaction(() async {
      final existing = await getMyWordById(id, accountId);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(id) & tbl.accountId.equals(accountId)))
          .write(
        MyWordsCompanion(
          word: Value(word),
          contents: Value(contents),
          editAt: Value(editAt),
          localRevision: Value(nextRevision),
        ),
      );
      return MyWordTableData(
        myWordId: id,
        word: word,
        contents: contents,
        editAt: editAt,
        accountId: existing.accountId,
        localRevision: nextRevision,
        remoteRevision: existing.remoteRevision,
        deletedAt: existing.deletedAt,
        lastMutationId: existing.lastMutationId,
      );
    });
  }

  /*
    return await transaction(() async {
      // 子テーブルのデータを削除
      await (delete(myWordStatus)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .go();
      final rows = await (delete(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) &
                tbl.accountId.equals(legacyOwner)))
          .go();
      return rows;
    });
  }

  */
  /// MyWord 行を物理削除せず論理削除する（`deleted_at` を設定し `local_revision` を増やす）。これにより
  /// トゥームストーンを同期でき、古いリモート更新で復活することはない。MyWordStatus はまだアウトボックス
  /// 契約の対象外のため、子ステータス行は物理削除する。未削除の一致行がない場合は `null` を返す。
  Future<MyWordTableData?> tombstoneMyWord(
      String wordId, String deletedAt, String accountId) {
    return transaction(() async {
      final existing = await getMyWordById(wordId, accountId);
      if (existing == null) return null;
      final nextRevision = existing.localRevision + 1;
      await (delete(myWordStatus)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .go();
      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .write(
        MyWordsCompanion(
          deletedAt: Value(DateTime.parse(deletedAt)),
          localRevision: Value(nextRevision),
        ),
      );
      return MyWordTableData(
        myWordId: wordId,
        word: existing.word,
        contents: existing.contents,
        editAt: existing.editAt,
        accountId: existing.accountId,
        localRevision: nextRevision,
        remoteRevision: existing.remoteRevision,
        deletedAt: DateTime.parse(deletedAt),
        lastMutationId: existing.lastMutationId,
      );
    });
  }

  Stream<MyWordTableData?> streamMyWordById(String id, String accountId) {
    return (select(myWords)
          ..where((tbl) =>
              tbl.myWordId.equals(id) &
              tbl.accountId.equals(accountId) &
              tbl.deletedAt.isNull()))
        .watchSingleOrNull()
        .distinct();
  }

  /// 1 つの未削除 MyWord と、同じアカウントに属するステータスだけを監視する。ステータスがない
  /// （またはトゥームストーン化されている）場合は、読み取りアダプターが書き込みなしで正規化できるよう
  /// 意図的に null を返す。
  Stream<MyWordItemRow?> watchMyWordItemRow(String id, String accountId) {
    final query = select(myWords).join([
      leftOuterJoin(
        myWordStatus,
        myWordStatus.myWordId.equalsExp(myWords.myWordId) &
            myWordStatus.accountId.equalsExp(myWords.accountId),
      ),
    ])
      ..where(
        myWords.myWordId.equals(id) &
            myWords.accountId.equals(accountId) &
            myWords.deletedAt.isNull(),
      );

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;
      final row = rows.single;
      return MyWordItemRow(
        word: row.readTable(myWords),
        status: row.readTableOrNull(myWordStatus),
      );
    });
  }

  /// 後続のローカル書き込みがリース済みリビジョンを置き換えていない場合にのみ、
  /// リモートトランザクションの確認応答を保存する。
  Future<bool> acknowledgeRemoteMutation({
    required String wordId,
    required String accountId,
    required int localRevision,
    required String remoteRevision,
    required String? lastMutationId,
  }) async {
    final changed = await (update(myWords)
          ..where((t) =>
              t.myWordId.equals(wordId) &
              t.accountId.equals(accountId) &
              t.localRevision.equals(localRevision)))
        .write(MyWordsCompanion(
      remoteRevision: Value(remoteRevision),
      lastMutationId: Value(lastMutationId),
    ));
    return changed == 1;
  }

  /// `local_revision` を増やしたりアウトボックスに触れたりせず、取得したリモートスナップショットをローカル行へ
  /// 適用する。これにより、リモート適用が新しいローカル編集として見えることはない。フィールドごとの `null` は
  /// 「変更しない」を意味する（同期ハンドラーが送信中のローカル変更を持つフィールドをスキップするために使用する）。
  /// null でない [deletedAt] は行をトゥームストーン化し（子ステータス行は物理削除）、すでにローカルで
  /// トゥームストーン化された行は、削除ではないリモート更新では変更しない。これにより古いリモート書き込みで復活しない。
  Future<void> applyRemoteFields(
    String wordId, {
    String? word,
    String? contents,
    String? deletedAt,
    required String editAt,
    required String accountId,
    String? remoteRevision,
    String? lastMutationId,
  }) {
    return transaction(() async {
      final existing = await (select(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .getSingleOrNull();

      if (existing != null && existing.deletedAt != null && deletedAt == null) {
        return;
      }

      if (existing == null) {
        await into(myWords).insert(
          MyWordsCompanion.insert(
            myWordId: wordId,
            word: word ?? '',
            contents: Value(contents),
            editAt: editAt,
            accountId: Value(accountId),
            localRevision: const Value(0),
            remoteRevision: Value(remoteRevision),
            lastMutationId: Value(lastMutationId),
            deletedAt:
                Value(deletedAt != null ? DateTime.parse(deletedAt) : null),
          ),
        );
        return;
      }

      await (update(myWords)
            ..where((tbl) =>
                tbl.myWordId.equals(wordId) & tbl.accountId.equals(accountId)))
          .write(
        MyWordsCompanion(
          word: word != null ? Value(word) : const Value.absent(),
          contents: contents != null ? Value(contents) : const Value.absent(),
          editAt: Value(editAt),
          deletedAt: deletedAt != null
              ? Value(DateTime.parse(deletedAt))
              : const Value.absent(),
          remoteRevision: remoteRevision != null
              ? Value(remoteRevision)
              : const Value.absent(),
          lastMutationId: lastMutationId != null
              ? Value(lastMutationId)
              : const Value.absent(),
        ),
      );

      if (deletedAt != null) {
        await (delete(myWordStatus)
              ..where((tbl) =>
                  tbl.myWordId.equals(wordId) &
                  tbl.accountId.equals(accountId)))
            .go();
      }
    });
  }
}
