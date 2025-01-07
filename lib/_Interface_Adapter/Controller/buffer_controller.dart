import 'package:my_dic/_Business_Rule/Usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';

class BufferController {
  final ISearchWordUseCase _searchWordUseCase;

  BufferController(this._searchWordUseCase);

  void execute(SearchWordOutputData input) {}

  void searchWord(String word) {
    if (word.isEmpty) {
      _searchWordUseCase.emptyExecute();
      return;
    }
    SearchWordInputData input = SearchWordInputData(word);
    _searchWordUseCase.execute(input);
  }
}
