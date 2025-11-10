import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_output_data.dart';

abstract class IJudgeSearchWordUseCase {
  JudgeSearchWordOutputData execute(JudgeSearchWordInputData input);
}
