import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';

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
  bool get hasResults => quizSearchedItems.isNotEmpty;
}
