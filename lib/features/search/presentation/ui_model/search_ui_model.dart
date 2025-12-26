import 'package:my_dic/core/shared/enums/dictionary/dictionary_type.dart';
import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

/// 検索画面の状態を表すクラス
class SearchState {
  final String query;
  final List<EspJpnWord> espJpnWords;
  final List<JpnEspWord> jpnEspWords;
  final List<SearchResultConjugacions> conjugacions;
  final bool isLoading;
  final String? errorMessage;

  SearchState({
    this.query = '',
    this.espJpnWords = const [],
    this.jpnEspWords = const [],
    this.conjugacions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  SearchState copyWith({
    String? query,
    List<EspJpnWord>? espJpnWords,
    List<JpnEspWord>? jpnEspWords,
    List<SearchResultConjugacions>? conjugacions,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      espJpnWords: espJpnWords ?? this.espJpnWords,
      jpnEspWords: jpnEspWords ?? this.jpnEspWords,
      conjugacions: conjugacions ?? this.conjugacions,
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
