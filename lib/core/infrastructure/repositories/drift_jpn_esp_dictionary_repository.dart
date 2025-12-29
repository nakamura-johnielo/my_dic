import 'package:my_dic/core/domain/entity/jpn_esp/example/jpn_esp_example.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_dictionary.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_dictionary_repository.dart';
import 'package:my_dic/core/domain/usecase/fetch_jpn_esp_dictionary/fetch_jpn_esp_dictionary_repository_input_data.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_dictionary_data_source.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class DriftJpnEspDictionaryRepository implements IJpnEspDictionaryRepository {
  final IJpnEspDictionaryLocalDataSource _dataSource;

  DriftJpnEspDictionaryRepository(this._dataSource);

  @override
  Future<Result<List<JpnEspDictionary>>> getDictionaryByWordId(
      FetchJpnEspDictionaryRepositoryInputData input) async {
    try {
      final res = await _dataSource.getDictionaryByWordId(input);
      return Result.success(res);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '和西辞書の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
