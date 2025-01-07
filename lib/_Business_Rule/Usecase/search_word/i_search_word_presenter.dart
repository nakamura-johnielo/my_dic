import 'package:my_dic/_Business_Rule/Usecase/search_word/search_word_output_data.dart';

abstract class ISearchWordPresenter {
  void execute(SearchWordOutputData input);
}
