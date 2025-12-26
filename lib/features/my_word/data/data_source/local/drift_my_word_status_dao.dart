import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:my_dic/features/my_word/data/data_source/local/my_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
part '../../../../../__generated/features/my_word/data/data_source/local/drift_my_word_status_dao.g.dart';

@DriftAccessor(tables: [MyWordStatus])
class MyWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$MyWordStatusDaoMixin {
  MyWordStatusDao(super.database);

  /* Future<void> updateStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    await (update(wordStatus)..where((t) => t.wordId.equals(id))).write(
        WordStatusCompanion(
            isLearned: Value(isLearned),
            isBookmarked: Value(isBookmarked),
            hasNote: Value(hasNote)));
  } */

  Future<void> updateStatus(MyWordStatusTableData data) async {
    log("update");
    await update(myWordStatus).replace(data);
  }

  /* Future<void> insertStatus(
      int id, int isLearned, int isBookmarked, int hasNote) async {
    into(wordStatus).insert(WordStatusData(
        wordId: id,
        isLearned: isLearned,
        isBookmarked: isBookmarked,
        hasNote: hasNote));
  } */

  Future<void> insertStatus(MyWordStatusTableData data) async {
    into(myWordStatus).insert(data);
    log("insert");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(myWordStatus)
          ..where((t) => t.myWordId.equals(id)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }
}
