import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacions.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';

abstract class IConjugacionsRepository {
  Future<Conjugacions?> getConjugacionByWordId(int id);
  Future<List<SearchResultConjugacions>> getConjugacionByWordWithPage(
      String word, int size, int currentPage);
  Future<List<QuizSearchedItem>> getQuizConjugacionByWordWithPage(
      String word, int size, int currentPage);
  //Future<List<Conjugacions>> getAllConjugacions();
  //Future<List<Conjugacions>> getSpecificTenseConjugacions();
}
