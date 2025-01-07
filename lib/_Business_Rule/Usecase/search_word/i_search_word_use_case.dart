import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_input_data.dart';

abstract class ISearchWordUseCase {
  void execute(SearchWordInputData input);
  void emptyExecute();
}
