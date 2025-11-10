import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/Entity/word_status.dart';
import 'package:my_dic/_Framework_Driver/Database/drift/database_provider.dart';

part '../../../../__generated/_Framework_Driver/Database/drift/DAO/word_status_dao.g.dart';

@DriftAccessor(tables: [WordStatus])
class WordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$WordStatusDaoMixin {
  WordStatusDao(super.database);

  /* Future<void> updateStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    await (update(wordStatus)..where((t) => t.wordId.equals(id))).write(
        WordStatusCompanion(
            isLearned: Value(isLearned),
            isBookmarked: Value(isBookmarked),
            hasNote: Value(hasNote)));
  } */

  Future<void> updateStatus(WordStatusData data) async {
    log("update");
    await update(wordStatus).replace(data);
  }

  Future<WordStatusData?> getStatusById(int wordId) {
    return (select(wordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  /* Future<void> insertStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    into(wordStatus).insert(WordStatusData(
        wordId: id,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote));
  } */

  Future<void> insertStatus(WordStatusData data) async {
    into(wordStatus).insert(data);
    log("insert");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(wordStatus)
          ..where((t) => t.wordId.equals(id)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }
}
