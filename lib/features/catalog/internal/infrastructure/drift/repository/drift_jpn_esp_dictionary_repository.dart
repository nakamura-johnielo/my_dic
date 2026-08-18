import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/jpn_esp_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class JpnEspDictionaryRepository implements IJpnEspDictionaryRepository {
  JpnEspDictionaryRepository(this._dataSource);
  final JpnEspDictionaryDataSource _dataSource;

  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
    int wordId,
  ) async {
    try {
      final data = await _dataSource.getDictionaryByWordId(wordId);
      return Result.success(CatalogDriftMapper.jpnEspDictionaries(data));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'jpn-esp dictionary query failed for wordId: $wordId',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
