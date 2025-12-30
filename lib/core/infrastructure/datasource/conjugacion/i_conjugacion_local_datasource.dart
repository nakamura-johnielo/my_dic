import 'package:my_dic/core/domain/entity/verb/conjugacions.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';

abstract class IConjugacionLocalDataSource {
  Future<EspConjugacions?> getConjugacionByWordId(int id);
  Future<List<SearchResultConjugacions>> getConjugacionByWordWithPage(
      String word, int size, int currentPage);
  Future<List<QuizSearchedItem>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage);
}
