import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/i_repository/i_jpn_esp_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/jpn_esp/i_jpn_esp_word_data_source.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/jpn_esp_word_converter.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';

/// Catalog repository only. Search projections are assembled by Search query.
class JpnEspWordRepository implements IJpnEspWordRepository {
  JpnEspWordRepository(this._wordDataSource);

  final IJpnEspWordLocalDataSource _wordDataSource;

  @override
  Future<Result<List<JpnEspWord>>> getWordsByWord(
    String word,
    int size,
    int currentPage,
  ) async {
    try {
      final rows =
          await _wordDataSource.getWordsByWord(word, size, currentPage);
      return Result.success(JpnEspWordConverter.toEntityList(rows));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to load Japanese-Spanish words.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
