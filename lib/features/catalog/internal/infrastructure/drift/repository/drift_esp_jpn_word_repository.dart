import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/esp_jpn_word_repository.dart';
import 'package:my_dic/features/catalog/internal/domain/word/esp_jpn_word.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/esp_jpn/esp_jpn_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class EsjWordRepository implements IEsjWordRepository {
  EsjWordRepository(this._dataSource);
  final IEsjWordLocalDataSource _dataSource;

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) =>
      _read(() => _dataSource.getWordsByWord(word));
  @override
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
    String word,
    int size,
    int currentPage,
    bool forQuiz,
  ) =>
      _read(() => _dataSource.getWordsByWordByPage(
            word,
            size,
            currentPage,
            forQuiz,
          ));
  @override
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
    String word,
    int size,
    int currentPage,
  ) =>
      _read(
          () => _dataSource.getQuizWordsByWordByPage(word, size, currentPage));

  Future<Result<List<EspJpnWord>>> _read(
    Future<List<EspJpnWordTableData>> Function() action,
  ) async {
    try {
      return Result.success(CatalogDriftMapper.espJpnWords(await action()));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to load Spanish-Japanese words.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
