import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/jpn-esp/jpn_esp_dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';


part '../../../../../../__generated/core/infrastructure/database/drift/daos/jpn_esp/jpn_esp_dictionary_dao.g.dart';

@DriftAccessor(tables: [JpnEspDictionaries])
class JpnEspDictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspDictionaryDaoMixin {
  JpnEspDictionaryDao(super.database);
  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<JpnEspDictionaryTableData>> getDictionaryByWordId(int wordId) {
    return (select(jpnEspDictionaries)
          ..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }
}
