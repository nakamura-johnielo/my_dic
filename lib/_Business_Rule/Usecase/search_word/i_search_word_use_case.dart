import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';

abstract class ISearchWordUseCase {
  Future<void> executeEspJpn(SearchWordInputData input);
  Future<List<QuizSearchedItem>> executeVerbs(SearchWordInputData input);
  Future<void> executeJpnEsp(SearchJpnEspWordInputData input);
  Future<void> emptyExecute();
  Future<void> executeConjugacion(SearchConjugacionInputData input);
}
