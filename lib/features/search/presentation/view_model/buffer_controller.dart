import 'dart:developer';

import 'package:my_dic/core/common/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_output_data.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_output_data.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';

class BufferController {
  final ISearchWordUseCase _searchWordUseCase;
  final IJudgeSearchWordUseCase _judgeSearchWordUseCase;

  BufferController(this._searchWordUseCase, this._judgeSearchWordUseCase);

  void execute(SearchWordOutputData input) {}

  Future<void> searchWord(String word, size, currentPage) async {
    log("LoadNext");
    //print("==word: $word");
    //const size = 50;
    //const currentPage = 0;
    //final requiredPage = currentPage + 1;
    final requiredPage = currentPage + 1;

    // ================空文字検索===================
    if (word.isEmpty) {
      final emptyRes = _searchWordUseCase.executeEmptyQuery();
      return;
    }

    JudgeSearchWordInputData judgeInput = JudgeSearchWordInputData(word);
    JudgeSearchWordOutputData res = _judgeSearchWordUseCase.execute(judgeInput);
    DictionaryType dictionaryType = res.dictionaryType;

    //=======和西で検索===================
    if (dictionaryType == DictionaryType.jpnEsp) {
      // _searchWordUseCase.execute(SearchWordInputData(word, dictionaryType: dictionaryType));
      SearchJpnEspWordInputData input =
          SearchJpnEspWordInputData(word, size, requiredPage);
      final result = await _searchWordUseCase.executeJpnEsp(input);

      return;
    }

    //=======西和で検索=========
    SearchWordInputData input =
        SearchWordInputData(word, size, requiredPage, false);
    final result = await _searchWordUseCase.executeEspJpn(input);

    //=========== 1番初めの４つはconjの結果=============
    if (requiredPage < 1) {
      int conjSize = 4;
      int conjPage = 0;
      SearchConjugacionInputData inputConj =
          SearchConjugacionInputData(word, conjSize, conjPage);
      await _searchWordUseCase.executeConjugacion(inputConj);
    }
  }

  Future<List<QuizSearchedItem>> searchVerbs(
      String word, size, currentPage) async {
    log("LoadNext");
    //print("==============word: $word");
    //const size = 50;
    //const currentPage = 0;
    final requiredPage = currentPage + 1;

    if (word.isEmpty) {
      //await _searchWordUseCase.emptyExecute();
      List<QuizSearchedItem> s = [];
      return s;
    }

    // JudgeSearchWordInputData judgeInput = JudgeSearchWordInputData(word);
    // JudgeSearchWordOutputData res = _judgeSearchWordUseCase.execute(judgeInput);
    // DictionaryType dictionaryType = res.dictionaryType;

    // if (dictionaryType == DictionaryType.jpnEsp) {
    //   //日本語で検索
    //   // _searchWordUseCase.execute(SearchWordInputData(word, dictionaryType: dictionaryType));
    //   SearchJpnEspWordInputData input =
    //       SearchJpnEspWordInputData(word, size, requiredPage);
    //   await _searchWordUseCase.executeJpnEsp(input);
    //   return;
    // }

    SearchWordInputData input =
        SearchWordInputData(word, size, requiredPage, true);
    List<QuizSearchedItem> results =
        await _searchWordUseCase.executeVerbs(input);
    return results;
    // if (requiredPage < 1) {
    //   int conjSize = 4;
    //   int conjPage = 0;
    //   SearchConjugacionInputData inputConj =
    //       SearchConjugacionInputData(word, conjSize, conjPage);
    //   await _searchWordUseCase.executeConjugacion(inputConj);
    // }
  }
}
