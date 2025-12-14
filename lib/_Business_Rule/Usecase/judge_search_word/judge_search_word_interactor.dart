import 'package:my_dic/core/common/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/_Business_Rule/Usecase/judge_search_word/judge_search_word_output_data.dart';

class JudgeSearchWordInteractor implements IJudgeSearchWordUseCase {
  JudgeSearchWordInteractor();

  @override
  JudgeSearchWordOutputData execute(JudgeSearchWordInputData input) {
    String word = input.searchWord;

    // アルファベットまたはスペイン語特殊文字を判定する正規表現
    bool isJustAlphabet = RegExp(r'[a-zA-ZñÑáéíóúÁÉÍÓÚüÜ]').hasMatch(word);
    DictionaryType dictionaryType = DictionaryType.espJpn;
    if (!isJustAlphabet) {
      dictionaryType = DictionaryType.jpnEsp;
    }
    JudgeSearchWordOutputData output =
        JudgeSearchWordOutputData(dictionaryType);
    return output;
  }
}
