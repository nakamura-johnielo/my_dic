import 'package:my_dic/_Business_Rule/_Domain/Entities/quiz_searched_item.dart';

/// 検索画面の状態を表すクラス
class QuizSearchState {
  final String query;
  final List<QuizSearchedItem> quizSearchedItems;
  final bool isLoading;
  final String? errorMessage;

  QuizSearchState({
    this.query = '',
    this.quizSearchedItems = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  QuizSearchState copyWith({
    String? query,
    List<QuizSearchedItem>? quizSearchedItems,
    bool? isLoading,
    String? errorMessage,
  }) {
    return QuizSearchState(
      query: query ?? this.query,
      quizSearchedItems: quizSearchedItems ?? this.quizSearchedItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 検索結果が空かどうか
  bool get hasResults =>
      quizSearchedItems.isNotEmpty ;

  /// 現在のアクティブな辞書タイプを判定
  // DictionaryType get activeDictionaryType {
  //   if (jpnEspWords.isNotEmpty) return DictionaryType.jpnEsp;
  //   if (quizSearchedItems.isNotEmpty || conjugacions.isNotEmpty) {
  //     return DictionaryType.espJpn;
  //   }
  //   return DictionaryType.espJpn; // デフォルト
  // }
}
