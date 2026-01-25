import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.g.dart';

@DriftAccessor(tables: [EspJpnWordStatus])
class EspJpnWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnWordStatusDaoMixin {
  EspJpnWordStatusDao(super.database);

  /* Future<void> updateStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    await (update(wordStatus)..where((t) => t.wordId.equals(id))).write(
        WordStatusCompanion(
            isLearned: Value(isLearned),
            isBookmarked: Value(isBookmarked),
            hasNote: Value(hasNote)));
  } */

  Stream<EspJpnWordStatusTableData?> watchWordStatus(int wordId) {
    // 変更された wordId のリストを監視するクエリを実装
    // ここでは単純に全てのレコードの wordId を返す例を示します
    return (select(espJpnWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .watchSingleOrNull()
        .distinct();
  }

  Stream<List<int>> watchChangedWordIdsWithFilter(DateTime since) {
    return (select(espJpnWordStatus)
          ..where(
              (tbl) => tbl.editAt.isBiggerThanValue(since.toIso8601String())))
        .watch()
        .map((rows) => rows.map((row) => row.wordId).toList())
        .distinct();
  }

  Future<void> updateStatus(
    int wordId,
    int? isLearned,
    int? isBookmarked,
    int? hasNote,
    String editAt,
  ) async {
    log("update");
    //await update(espJpnWordStatus).replace(data);
    await (update(espJpnWordStatus)..where((t) => t.wordId.equals(wordId)))
        .write(
      EspJpnWordStatusCompanion(
        //wordId: Value(wordId),
        isLearned: isLearned != null ? Value(isLearned) : Value.absent(),
        isBookmarked:
            isBookmarked != null ? Value(isBookmarked) : Value.absent(),
        hasNote: hasNote != null ? Value(hasNote) : Value.absent(),
        editAt: Value(editAt),
      ),
    );
  }

  Future<EspJpnWordStatusTableData?> getStatusById(int wordId) {
    return (select(espJpnWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.editAt.isBiggerThanValue(datetime.toIso8601String())))
        .get();
  }

  /* Future<void> insertStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    into(espJpnWordStatus).insert(EspJpnWordStatusTableData(
        wordId: id,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote));
  } */

  Future<void> insertStatus(EspJpnWordStatusTableData data) async {
    await into(espJpnWordStatus).insert(data);
    log("insert");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(espJpnWordStatus)
          ..where((t) => t.wordId.equals(id)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }
}
