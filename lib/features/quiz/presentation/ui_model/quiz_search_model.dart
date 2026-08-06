import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';

/// 検索画面の状態を表すクラス
class QuizSearchState {
  final String query;
  final List<ConjugacionSearchResultItem> quizSearchedItems;
  final bool isLoading;
  final String? errorMessage;
  
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;

  QuizSearchState({
    this.query = '',
    this.quizSearchedItems = const [],
    this.isLoading = false,
    this.errorMessage,
    this.rankingNos = const {}, this.simpleMeanings = const {}, this.starCounts = const {}, 
  });

  QuizSearchState copyWith({
    String? query,
    List<ConjugacionSearchResultItem>? quizSearchedItems,
    bool? isLoading,
    String? errorMessage,
    Map<int, int>? rankingNos,
    Map<int, String>? simpleMeanings,
    Map<int, int>? starCounts,
  }) {
    return QuizSearchState(
      query: query ?? this.query,
      quizSearchedItems: quizSearchedItems ?? this.quizSearchedItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      rankingNos: rankingNos ?? this.rankingNos,
      simpleMeanings: simpleMeanings ?? this.simpleMeanings,  
      starCounts: starCounts ?? this.starCounts,
    );
  }

  /// 検索結果が空かどうか
  bool get hasResults => quizSearchedItems.isNotEmpty;
}
