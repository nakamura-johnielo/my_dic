import 'package:drift/drift.dart';
import 'package:my_dic/_Framework_Driver/local/drift/Entity/jpn-esp/jpn_esp_dictionaries.dart';
import 'package:my_dic/_Framework_Driver/local/drift/database_provider.dart';

part '../../../../../__generated/_Framework_Driver/Database/drift/DAO/jpn_esp/jpn_esp_dictionary_dao.g.dart';

@DriftAccessor(tables: [JpnEspDictionaries])
class JpnEspDictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$JpnEspDictionaryDaoMixin {
  JpnEspDictionaryDao(super.database);
  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<JpnEspDictionary>> getDictionaryByWordId(int wordId) {
    return (select(jpnEspDictionaries)
          ..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }
}
