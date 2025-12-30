import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_output_data.dart';

abstract class IJudgeSearchWordUseCase {
  Result<JudgeSearchWordOutputData> execute(JudgeSearchWordInputData input);
}
