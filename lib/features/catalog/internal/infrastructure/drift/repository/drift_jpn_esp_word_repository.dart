import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/internal/domain/repository/jpn_esp_word_repository.dart';
import 'package:my_dic/features/catalog/internal/domain/word/jpn_esp_word.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/datasource/jpn_esp/jpn_esp_word_data_source.dart';
import 'package:my_dic/features/catalog/internal/infrastructure/drift/mapper/catalog_drift_mapper.dart';

class JpnEspWordRepository implements IJpnEspWordRepository {
  JpnEspWordRepository(this._dataSource);
  final IJpnEspWordLocalDataSource _dataSource;

  @override
  Future<Result<List<JpnEspWord>>> getWordsByWord(
    String word,
    int size,
    int currentPage,
  ) async {
    try {
      final rows = await _dataSource.getWordsByWord(word, size, currentPage);
      return Result.success(CatalogDriftMapper.jpnEspWords(rows));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to load Japanese-Spanish words.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
