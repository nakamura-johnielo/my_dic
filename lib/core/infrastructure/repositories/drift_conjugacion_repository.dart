
import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/i_repository/i_conjugation_repository.dart';
import 'package:my_dic/core/infrastructure/datasource/conjugacion/i_conjugacion_local_datasource.dart';
import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/core/shared/errors/infrastructure_errors.dart';

class DriftConjugacionRepository implements IConjugacionsRepository {
  final IConjugacionLocalDataSource _dataSource;
  DriftConjugacionRepository(this._dataSource);

  // @override
  // Future<Conjugacions?> getConjugacionByWordId(int id)async {
  //   final res = await _conjugacionDao.getConjugationById(id);
  //   if (res == null) {
  //     return null; // 結果がnullの場合はnullを返す
  //   }
  //   return Conjugacions(wordId: res.wordId, conjugacions: convertToConjugations(res));
  // }
  @override
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id) async {
    try {
      final res = await _dataSource.getConjugacionByWordId(id);
      return Result.success(res);
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
      print("================================{conjugaciones?.length}");
        final conjugaciones = await _dataSource.getConjugacionByWordWithPage(
          word, size, currentPage);
      List<SearchResultConjugacions> res = [];
      if (conjugaciones == null) return Result.success(res);

      return Result.success(conjugaciones);
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
        final conjugaciones = await _dataSource.getQuizConjugacionByWordWithPage(word, size, currentPage);
      List<QuizSearchedItem> res = [];
      if (conjugaciones == null) return Result.success(res);

      
      return Result.success(conjugaciones);
    } catch (e, stackTrace) {
      return Result.failure(DatabaseError(
        message: 'クイズ用活用形検索に失敗しました',
        originalError: e,
        stackTrace: stackTrace,
      ));
    }
  }

 }
