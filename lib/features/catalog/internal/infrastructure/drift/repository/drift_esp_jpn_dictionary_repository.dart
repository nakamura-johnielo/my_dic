import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/i_repository/esp_jpn_dictionary_store.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class EspJpnDictionaryRepository implements IEspJpnDictionaryRepository {
  EspJpnDictionaryRepository(this._dataSource);
  final EspJpnDictionaryDataSource _dataSource;

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(
      int wordId) async {
    try {
      final data = await _dataSource.getDictionaryByWordId(wordId);
      if (data.isEmpty) {
        return Result.failure(NotFoundError(
          message: 'esp-jpn-dictionary notfound for wordId: $wordId',
        ));
      }
      return Result.success(CatalogDriftMapper.espJpnDictionaries(data));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'esp-jpn-dictionary query failed for wordId: $wordId',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
