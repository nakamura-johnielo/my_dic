import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/words.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/query/catalog_like_pattern.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/esp_jpn/esp_jpn_word_dao.g.dart';

@DriftAccessor(tables: [EspJpnWords])
class EspJpnWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspJpnWordDaoMixin {
  EspJpnWordDao(super.database);

  Future<EspJpnWordTableData?> getDictionaryByWordId(int wordId) {
    return (select(espJpnWords)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<List<EspJpnWordTableData>> getWordsByWord(String searchWord) async {
    return (select(espJpnWords)
          ..where((tbl) => tbl.word.like(
                catalogPrefixLikePattern(searchWord),
                escapeChar: catalogLikeEscapeCharacter,
              )))
        .get();
  }

  Future<List<EspJpnWordTableData>> getWordsByWordByPage(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(espJpnWords)
          ..where((tbl) => tbl.word.like(
                catalogPrefixLikePattern(searchWord),
                escapeChar: catalogLikeEscapeCharacter,
              ))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
