import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_word.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/catalog_like_pattern.dart';

part '../../../../../../../__generated/features/catalog/internal/infrastructure/drift/dao/jpn_esp/jpn_esp_word_dao.g.dart';

@DriftAccessor(tables: [JpnEspWords])
class JpnEspWordDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspWordDaoMixin {
  JpnEspWordDao(super.database);

  Future<JpnEspWordTableData?> getDictionaryByWordId(int wordId) {
    return (select(jpnEspWords)..where((tbl) => tbl.wordId.equals(wordId)))
        .getSingleOrNull();
  }

  Future<List<JpnEspWordTableData>> getWordsByWord(
      String searchWord, int size, int currentPage) async {
    final int offset = size * currentPage; // ページ番号に基づいてスキップする件数を計算

    return (select(jpnEspWords)
          ..where((tbl) => tbl.word.like(
                catalogPrefixLikePattern(searchWord),
                escapeChar: catalogLikeEscapeCharacter,
              ))
          ..limit(size, offset: offset)) // limit と offset を追加
        .get();
  }
}
