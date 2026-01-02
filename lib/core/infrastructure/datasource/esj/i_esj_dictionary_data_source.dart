import 'package:my_dic/core/infrastructure/datasource/esj/esj_dictionary_dataset.dart';

abstract class IEsjDictionaryLocalDataSource {
  Future<List<EsjDictionaryDataSet>> getDictionaryByWordId(int wordId);
}
