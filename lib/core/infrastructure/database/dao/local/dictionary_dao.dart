import 'package:drift/drift.dart';
import 'package:my_dic/core/infrastructure/database/table/dictionaries.dart';
import 'package:my_dic/core/infrastructure/database/table/examples.dart';
import 'package:my_dic/core/infrastructure/database/database_provider.dart';
import 'package:tuple/tuple.dart';

part '../../../../../__generated/core/infrastructure/database/dao/local/dictionary_dao.g.dart';

@DriftAccessor(tables: [Dictionaries, Examples])
class DictionaryDao extends DatabaseAccessor<DatabaseProvider>
    with _$DictionaryDaoMixin {
  //DictionaryDao(DatabaseProvider db) : super(db);
  DictionaryDao(super.database);

  // 特定のword_idに基づいてエントリを取得するメソッド
  Future<List<Dictionary>> getDictionaryByWordId(int wordId) {
    return (select(dictionaries)..where((tbl) => tbl.wordId.equals(wordId)))
        .get();
  }

  // 結合クエリを使用して特定の単語に関連する例文を取得するメソッド
  Future<List<Tuple2<Dictionary, Example>>> getDictionaryWithExamples(
      int wordId) {
    final query = select(dictionaries).join([
      innerJoin(
          examples, examples.dictionaryId.equalsExp(dictionaries.dictionaryId))
    ])
      ..where(dictionaries.wordId.equals(wordId));
    return query.map((row) {
      return Tuple2(row.readTable(dictionaries), row.readTable(examples));
    }).get();
  }
}
