import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/drift/tables/esp_jpn/examples.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:tuple/tuple.dart';

part '../../../../../../__generated/core/infrastructure/database/drift/daos/esp_jpn/dictionary_dao.g.dart';


@DriftAccessor(tables: [EspJpnDictionaries, EspJpnExamples])
class EspjpnDictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$EspjpnDictionaryDaoMixin {
  //DictionaryDao(DatabaseProvider db) : super(db);
  EspjpnDictionaryDao(super.database);

  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<EspJpnDictionaryTableData>> getDictionaryByWordId(int wordId) {
    return (select(espJpnDictionaries)..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }

  // 結合クエリを使用して特定の単語に関連する例文を取得するメソッド
  Future<List<Tuple2<EspJpnDictionaryTableData, EspJpnExampleTableData>>>
      getDictionaryWithExamples(int wordId) {
    final query = select(espJpnDictionaries).join([
      innerJoin(
          espJpnExamples, espJpnExamples.dictionaryId.equalsExp(espJpnDictionaries.dictionaryId))
    ])
      ..where(espJpnDictionaries.wordId.equals(wordId));
    return query.map((row) {
      return Tuple2(row.readTable(espJpnDictionaries), row.readTable(espJpnExamples));
    }).get();
  }
}
