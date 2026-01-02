import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/esj_dictionary_converter.dart';

class EsjDictionaryRepository implements IEsjDictionaryRepository {
  final IEsjDictionaryLocalDataSource _dataSource;
  EsjDictionaryRepository(this._dataSource);

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int wordId) async {
    try {
      final dataSets = await _dataSource.getDictionaryByWordId(wordId);
      if (dataSets.isEmpty) {
        return Result.failure(NotFoundError(
          message: '辞書データが見つかりません',
        ));
      }
      final entities = EsjDictionaryConverter.toEntityList(dataSets);
      return Result.success(entities);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '辞書データの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}
