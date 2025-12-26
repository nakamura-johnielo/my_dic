import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_output_data.dart';

abstract class ISearchWordUseCase {
  Future<Result<SearchWordOutputData>> executeEspJpn(SearchWordInputData input);
  Future<List<QuizSearchedItem>> executeVerbs(SearchWordInputData input);
  SearchWordOutputData executeEmptyQuery();
  Future<Result<SearchJpnEspWordOutputData>> executeJpnEsp(
      SearchJpnEspWordInputData input);
  Future<Result<SearchConjugacionOutputData>> executeConjugacion(
      SearchConjugacionInputData input);
}
