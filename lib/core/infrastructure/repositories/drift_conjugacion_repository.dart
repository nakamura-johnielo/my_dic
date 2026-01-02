
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';
import 'package:my_dic/core/infrastructure/repositories/converters/conjugacion_converter.dart';

class ConjugacionRepository implements IConjugacionsRepository {
  final IConjugacionLocalDataSource _dataSource;
  ConjugacionRepository(this._dataSource);

  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async {
    try {
      final tableData = await _dataSource.getConjugacionByWordId(id);
      final entity = ConjugacionConverter.toEntity(tableData);
      return Result.success(entity);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '活用形の取得に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    try {
      final tableDataList = await _dataSource.getConjugacionByWordWithPage(
          word, size, currentPage);
      final entities = tableDataList.map((data) => 
        ConjugacionConverter.toSearchResult(data)).toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: '活用形検索に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

  @override
  Future<Result<List<QuizSearchedItem>>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage) async {
    try {
      final tableDataList = await _dataSource.getQuizConjugacionByWordWithPage(
          word, size, currentPage);
      final entities = tableDataList.map((data) => 
        ConjugacionConverter.toQuizItem(data)).toList();
      return Result.success(entities);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'クイズ用活用形検索に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }
}
