// lib/features/search/presentation/view_model/search_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/core/common/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/i_judge_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/judge_search_word/judge_search_word_input_data.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';
import 'package:my_dic/features/search/presentation/ui_model/search_ui_model.dart';

/// 検索画面のViewModel
class SearchViewModel extends StateNotifier<SearchState> {
  final ISearchWordUseCase _searchWordUseCase;
  final IJudgeSearchWordUseCase _judgeSearchWordUseCase;

  SearchViewModel(
    this._searchWordUseCase,
    this._judgeSearchWordUseCase,
  ) : super(SearchState());

  // ==================== Public Methods ====================

  /// 検索クエリを更新
  void updateQuery(String query) {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      clearResults();
    }

    state = state.copyWith(query: trimmedQuery);
  }

  Future<void> loadSearchResults(int size, int currentPage) async {
    final word = state.query;
    if (word.isEmpty) {
      clearResults();
      return;
    }
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    final nextPage = currentPage + 1;

    try {
      final dictionaryType = _judgeDictionaryType(word);
      print("#############Viewmodel nextpage:$nextPage");

      if (dictionaryType == DictionaryType.jpnEsp) {
        await _searchJpnEsp(word, size: size, page: nextPage);
      } else {
        print("#############true");
        await _searchEspJpn(word, size: size, page: nextPage);
        if (nextPage == 0) {
          // 初回のみ活用形も検索
          await _searchConjugacion(word, size: 4, page: 0);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load next page: $e',
      );
    }
  }

  /// 検索結果をクリア
  void clearResults() {
    state = state.copyWith(
      //query: '',
      espJpnWords: [],
      jpnEspWords: [],
      conjugacions: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  // ==================== Private Methods ====================

  /// 辞書タイプを判定
  DictionaryType _judgeDictionaryType(String word) {
    final judgeInput = JudgeSearchWordInputData(word);
    final result = _judgeSearchWordUseCase.execute(judgeInput);
    return result.dictionaryType;
  }

  /// 西和検索
  Future<void> _searchEspJpn(String word,
      {required int size, required int page}) async {
    final input = SearchWordInputData(word, size, page, false);
    final result = await _searchWordUseCase.executeEspJpn(input);
    print("result length " + result.wordList.length.toString());

    if (page == 0) {
      // 初回は置き換え
      state = state.copyWith(
        espJpnWords: result.wordList,
        jpnEspWords: [],
        isLoading: false,
      );
    } else {
      // 追加読み込みは追加
      state = state.copyWith(
        espJpnWords: [...state.espJpnWords, ...result.wordList],
        isLoading: false,
      );
    }
  }

  /// 和西検索
  Future<void> _searchJpnEsp(String word,
      {required int size, required int page}) async {
    final input = SearchJpnEspWordInputData(word, size, page);
    final result = await _searchWordUseCase.executeJpnEsp(input);

    if (page == 0) {
      state = state.copyWith(
        jpnEspWords: result.wordList,
        espJpnWords: [],
        conjugacions: [],
        isLoading: false,
      );
    } else {
      state = state.copyWith(
        jpnEspWords: [...state.jpnEspWords, ...result.wordList],
        isLoading: false,
      );
    }
  }

  /// 活用形検索
  Future<void> _searchConjugacion(String word,
      {required int size, required int page}) async {
    final input = SearchConjugacionInputData(word, size, page);
    final result = await _searchWordUseCase.executeConjugacion(input);

    print("##############conjlength:${result.wordList.length}");
    state = state.copyWith(
      conjugacions: result.wordList,
    );
  }
}
