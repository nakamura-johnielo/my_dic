import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

/// 検索画面の状態を表すクラス
class SearchState {
  //TODO ranking,simplemeaning
  
  final String query;
  final List<EspJpnWord> espJpnWords;
  final List<JpnEspWord> jpnEspWords;
  final List<SearchResultConjugacions> conjugacions;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  final bool isLoading;
  final String? errorMessage;

  SearchState({
    this.query = '',
    this.espJpnWords = const [],
    this.jpnEspWords = const [],
    this.conjugacions = const [],
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    List<EspJpnWord>? espJpnWords,
    List<JpnEspWord>? jpnEspWords,
    List<SearchResultConjugacions>? conjugacions,
    Map<int, int>? rankingNos,
    Map<int, String>? simpleMeanings,
    Map<int, int>? starCounts,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      espJpnWords: espJpnWords ?? this.espJpnWords,
      jpnEspWords: jpnEspWords ?? this.jpnEspWords,
      conjugacions: conjugacions ?? this.conjugacions,
      rankingNos: rankingNos ?? this.rankingNos,
      simpleMeanings: simpleMeanings ?? this.simpleMeanings,
      starCounts: starCounts ?? this.starCounts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 検索結果が空かどうか
  bool get hasResults =>
      espJpnWords.isNotEmpty ||
      jpnEspWords.isNotEmpty ||
      conjugacions.isNotEmpty;

  /// 現在のアクティブな辞書タイプを判定
  DictionaryType get activeDictionaryType {
    if (jpnEspWords.isNotEmpty) return DictionaryType.jpnEsp;
    if (espJpnWords.isNotEmpty || conjugacions.isNotEmpty) {
      return DictionaryType.espJpn;
    }
    return DictionaryType.espJpn; // デフォルト
  }
}
