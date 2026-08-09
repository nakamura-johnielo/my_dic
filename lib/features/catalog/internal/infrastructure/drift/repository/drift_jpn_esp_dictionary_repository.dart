import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/jpn_esp_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/jpn_esp_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class JpnEspDictionaryRepository implements IJpnEspDictionaryRepository {
  JpnEspDictionaryRepository(this._dataSource);
  final IJpnEspDictionaryLocalDataSource _dataSource;

  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
    int wordId,
  ) async {
    try {
      final data = await _dataSource.getDictionaryByWordId(wordId);
      return Result.success(CatalogDriftMapper.jpnEspDictionaries(data));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '蜥瑚･ｿ霎樊嶌縺ｮ蜿門ｾ励↓螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
