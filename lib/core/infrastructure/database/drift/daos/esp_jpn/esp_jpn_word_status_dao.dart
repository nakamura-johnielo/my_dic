import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/esp_jpn_word_status_dao.g.dart';

@DriftAccessor(tables: [EspJpnWordStatus])
class EspJpnWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnWordStatusDaoMixin {
  EspJpnWordStatusDao(super.database);

  Stream<EspJpnWordStatusTableData?> watchWordStatus(int wordId) {
    return (select(espJpnWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .watchSingleOrNull()
        .distinct();
  }

  Stream<List<int>> watchChangedWordIdsWithFilter(DateTime since) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.editAt.isBiggerOrEqualValue(since.toIso8601String())))
        .watch()
        .map((rows) => rows.map((row) => row.wordId).toList())
        .distinct();
  }

  Future<EspJpnWordStatusTableData> applyStatusPatch(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  ) async {
    return transaction(() async {
      final existing = await getStatusById(wordId);
      if (existing == null) {
        await into(espJpnWordStatus).insert(
          EspJpnWordStatusCompanion.insert(
            wordId: Value(wordId),
            isLearned: Value(isLearned == true ? 1 : 0),
            isBookmarked: Value(isBookmarked == true ? 1 : 0),
            hasNote: Value(hasNote == true ? 1 : 0),
            editAt: editAt,
          ),
        );
      } else {
        await (update(espJpnWordStatus)..where((t) => t.wordId.equals(wordId)))
            .write(
          EspJpnWordStatusCompanion(
            isLearned: isLearned != null
                ? Value(isLearned ? 1 : 0)
                : const Value.absent(),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked ? 1 : 0)
                : const Value.absent(),
            hasNote:
                hasNote != null ? Value(hasNote ? 1 : 0) : const Value.absent(),
            editAt: Value(editAt),
          ),
        );
      }

      final updated = await getStatusById(wordId);
      if (updated == null) {
        throw StateError('Esp-Jpn word status was not persisted: $wordId');
      }
      AppLogger.print("update");
      return updated;
    });
  }

  Future<EspJpnWordStatusTableData?> getStatusById(int wordId) {
    return (select(espJpnWordStatus)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<List<EspJpnWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) {
    return (select(espJpnWordStatus)
          ..where((tbl) =>
              tbl.editAt.isBiggerOrEqualValue(datetime.toIso8601String())))
        .get();
  }

  Future<void> insertStatus(EspJpnWordStatusTableData data) async {
    await into(espJpnWordStatus).insert(data);
    AppLogger.print("insert");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(espJpnWordStatus)
          ..where((t) => t.wordId.equals(id)))
        .getSingleOrNull();
    return existingColum != null ? true : false;
  }
}
