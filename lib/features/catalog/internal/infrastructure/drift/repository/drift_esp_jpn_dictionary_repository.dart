import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/dictionary_entry/esp_jpn_dictionary.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/esp_jpn_dictionary_repository.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_dictionary_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class EsjDictionaryRepository implements IEsjDictionaryRepository {
  EsjDictionaryRepository(this._dataSource);
  final IEsjDictionaryLocalDataSource _dataSource;

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(
      int wordId) async {
    try {
      final data = await _dataSource.getDictionaryByWordId(wordId);
      if (data.isEmpty) {
        return Result.failure(NotFoundError(
          message: '霎樊嶌繝・・繧ｿ縺瑚ｦ九▽縺九ｊ縺ｾ縺帙ｓ',
        ));
      }
      return Result.success(CatalogDriftMapper.espJpnDictionaries(data));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: '霎樊嶌繝・・繧ｿ縺ｮ蜿門ｾ励↓螟ｱ謨励＠縺ｾ縺励◆',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
