import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.g.dart';

@DriftAccessor(tables: [JpnEspWordStatus])
class JpnEspWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordStatusDaoMixin {
  JpnEspWordStatusDao(super.database);

  Stream<JpnEspWordStatusTableData?> watchWordStatus(int wordId) {
    return (select(jpnEspWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .watchSingleOrNull()
        .distinct();
  }

  Stream<List<int>> watchChangedWordIdsWithFilter(DateTime since) {
    return (select(jpnEspWordStatus)
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
    AppLogger.print("update jpn_esp word status");
    await (update(jpnEspWordStatus)..where((t) => t.wordId.equals(wordId)))
        .write(
      JpnEspWordStatusCompanion(
        isLearned: isLearned != null ? Value(isLearned) : Value.absent(),
        isBookmarked:
            isBookmarked != null ? Value(isBookmarked) : Value.absent(),
        hasNote: hasNote != null ? Value(hasNote) : Value.absent(),
        editAt: Value(editAt),
      ),
    );
  }

  Future<JpnEspWordStatusTableData?> getStatusById(int wordId) {
    return (select(jpnEspWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) {
    return (select(jpnEspWordStatus)
          ..where((tbl) =>
              tbl.editAt.isBiggerThanValue(datetime.toIso8601String())))
        .get();
  }

  Future<void> insertStatus(JpnEspWordStatusTableData data) async {
    await into(jpnEspWordStatus).insert(data);
    AppLogger.print("insert jpn_esp word status");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(jpnEspWordStatus)
          ..where((t) => t.wordId.equals(id)))
        .getSingleOrNull();
    return existingColum != null;
  }
}
