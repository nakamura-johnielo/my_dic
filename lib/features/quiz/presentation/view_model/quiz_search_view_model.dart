// lib/features/search/presentation/view_model/search_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/features/quiz/presentation/ui_model/quiz_search_model.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/i_search_word_use_case.dart';
import 'package:my_dic/features/search/domain/usecase/search_word/search_word_input_data.dart';

/// 検索画面のViewModel
class QuizSearchViewModel extends StateNotifier<QuizSearchState> {
  final ISearchWordUseCase _searchWordUseCase;

  QuizSearchViewModel(
    this._searchWordUseCase,
  ) : super(QuizSearchState());

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
      await _searchQuizEnableWord(word, size: size, page: nextPage);
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
      quizSearchedItems: [],
      isLoading: false,
      errorMessage: null,
    );
  }

  // ==================== Private Methods ====================

  /// 和西検索
  Future<void> _searchQuizEnableWord(String word,
      {required int size, required int page}) async {
    final input = SearchWordInputData(word, size, page , true);
    final result = await _searchWordUseCase.executeVerbs(input);

    state = state.copyWith(
      quizSearchedItems: [...state.quizSearchedItems, ...result],
      isLoading: false,
    );
  }
}
