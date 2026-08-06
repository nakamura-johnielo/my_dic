import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word_status.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/utils/logger.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_word_status_dao.g.dart';

@DriftAccessor(tables: [JpnEspWordStatus])
class JpnEspWordStatusDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordStatusDaoMixin {
  JpnEspWordStatusDao(super.database);
  static const legacyOwner = 'legacy_unowned';

  Stream<JpnEspWordStatusTableData?> watchWordStatus(int wordId) {
    return (select(jpnEspWordStatus)
          ..where((tbl) =>
              tbl.wordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
        .watchSingleOrNull()
        .distinct();
  }

  Stream<List<int>> watchChangedWordIdsWithFilter(DateTime since) {
    return (select(jpnEspWordStatus)
          ..where((tbl) =>
              tbl.accountId.equals(legacyOwner) &
              tbl.editAt.isBiggerThanValue(since.toIso8601String())))
        .watch()
        .map((rows) => rows.map((row) => row.wordId).toList())
        .distinct();
  }

  Future<JpnEspWordStatusTableData> applyStatusPatch(
    int wordId,
    bool? isLearned,
    bool? isBookmarked,
    bool? hasNote,
    String editAt,
  ) async {
    return transaction(() async {
      final existing = await getStatusById(wordId);
      final nextRevision = (existing?.localRevision ?? 0) + 1;
      if (existing == null) {
        await into(jpnEspWordStatus).insert(
          JpnEspWordStatusCompanion.insert(
            wordId: wordId,
            isLearned: Value(isLearned == true ? 1 : 0),
            isBookmarked: Value(isBookmarked == true ? 1 : 0),
            hasNote: Value(hasNote == true ? 1 : 0),
            editAt: editAt,
            accountId: const Value(legacyOwner),
            localRevision: Value(nextRevision),
          ),
        );
      } else {
        await (update(jpnEspWordStatus)
              ..where((t) =>
                  t.wordId.equals(wordId) & t.accountId.equals(legacyOwner)))
            .write(
          JpnEspWordStatusCompanion(
            isLearned: isLearned != null
                ? Value(isLearned ? 1 : 0)
                : const Value.absent(),
            isBookmarked: isBookmarked != null
                ? Value(isBookmarked ? 1 : 0)
                : const Value.absent(),
            hasNote:
                hasNote != null ? Value(hasNote ? 1 : 0) : const Value.absent(),
            editAt: Value(editAt),
            localRevision: Value(nextRevision),
          ),
        );
      }

      final updated = await getStatusById(wordId);
      if (updated == null) {
        throw StateError('Jpn-Esp word status was not persisted: $wordId');
      }
      AppLogger.print("update jpn_esp word status");
      return updated;
    });
  }

  Future<JpnEspWordStatusTableData?> getStatusById(int wordId) {
    return (select(jpnEspWordStatus)
          ..where((tbl) =>
              tbl.wordId.equals(wordId) & tbl.accountId.equals(legacyOwner)))
        .getSingleOrNull();
  }

  Future<List<JpnEspWordStatusTableData>> getWordStatusAfter(
      DateTime datetime) {
    return (select(jpnEspWordStatus)
          ..where((tbl) =>
              tbl.accountId.equals(legacyOwner) &
              tbl.editAt.isBiggerThanValue(datetime.toIso8601String())))
        .get();
  }

  Future<void> insertStatus(JpnEspWordStatusTableData data) async {
    await into(jpnEspWordStatus).insert(data);
    AppLogger.print("insert jpn_esp word status");
  }

  Future<bool> exist(int id) async {
    final existingColum = await (select(jpnEspWordStatus)
          ..where((t) => t.wordId.equals(id) & t.accountId.equals(legacyOwner)))
        .getSingleOrNull();
    return existingColum != null;
  }
}
