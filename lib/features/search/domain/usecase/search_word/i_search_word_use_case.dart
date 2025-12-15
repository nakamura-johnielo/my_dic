import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_output_data.dart';

abstract class ISearchWordUseCase {
  Future<SearchWordOutputData> executeEspJpn(SearchWordInputData input);
  Future<List<QuizSearchedItem>> executeVerbs(SearchWordInputData input);
  Future<SearchJpnEspWordOutputData> executeJpnEsp(
      SearchJpnEspWordInputData input);
  SearchWordOutputData executeEmptyQuery();
  Future<SearchConjugacionOutputData> executeConjugacion(
      SearchConjugacionInputData input);
}
