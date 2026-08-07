import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/core/domain/i_repository/i_esj_word_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/esj/i_esj_word_data_source.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/esj_word_converter.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/shared/utils/result.dart';

/// Catalog repository only. Search-specific enrichment belongs to Search query.
class EsjWordRepository implements IEsjWordRepository {
  EsjWordRepository(this._wordDataSource);

  final IEsjWordLocalDataSource _wordDataSource;

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWord(String word) =>
      _read(() => _wordDataSource.getWordsByWord(word));

  @override
  Future<Result<List<EspJpnWord>>> getWordsByWordByPage(
    String word,
    int size,
    int currentPage,
    bool forQuiz,
  ) =>
      _read(
        () => _wordDataSource.getWordsByWordByPage(
          word,
          size,
          currentPage,
          forQuiz,
        ),
      );

  @override
  Future<Result<List<EspJpnWord>>> getQuizWordsByWordByPage(
    String word,
    int size,
    int currentPage,
  ) =>
      _read(
        () => _wordDataSource.getQuizWordsByWordByPage(
          word,
          size,
          currentPage,
        ),
      );

  Future<Result<List<EspJpnWord>>> _read(
    Future<List<EspJpnWordTableData>> Function() action,
  ) async {
    try {
      return Result.success(EsjWordConverter.toEntityList(await action()));
    } catch (error, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'Unable to load Spanish-Japanese words.',
        originalError: error,
        stackTrace: stackTrace,
      ));
    }
  }
}
