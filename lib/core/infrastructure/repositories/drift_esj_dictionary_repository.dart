import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_dictionary_data_source.dart';
import 'package:my_dic/core/shared/errors/domain_errors.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/domain/entity/dictionary/esj_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_dictionary_repository.dart';

class DriftEsjDictionaryRepository implements IEsjDictionaryRepository {
  final IEsjDictionaryLocalDataSource _dataSource;
  DriftEsjDictionaryRepository(this._dataSource);

  @override
  Future<Result<List<EspJpnDictionary>>> getDictionaryByWordId(int wordId) async {
    try {
      final res = await _dataSource.getDictionaryByWordId(wordId);
      if (res.isEmpty) {
        return Result.failure(NotFoundError(
          message: '辞書データが見つかりません',
        ));
      }
      return Result.success(res);
    } catch (e, s) {
      return Result.failure(DatabaseError(
        message: '辞書データの取得に失敗しました',
        originalError: e,
        stackTrace: s,
      ));
    }
  }
}
