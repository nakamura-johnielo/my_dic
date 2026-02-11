import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/shared/utils/result.dart';

abstract class IConjugacionsRepository {
  Future<Result<EspConjugacions?>> getConjugacionByWordId(int id);
  Future<Result<List<SearchResultConjugacions>>> getConjugacionByWordWithPage(
      String word, int size, int currentPage);
  Future<Result<List<QuizSearchedItem>>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage);
  Future<Result<bool>> hasConjByWordId(int wordId);
}
