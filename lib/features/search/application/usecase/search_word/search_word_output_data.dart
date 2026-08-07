import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/conjugacion_search_result_item.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

class SearchWordOutputData {
  final List<EspJpnWord> wordList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  const SearchWordOutputData(this.wordList,
      {this.rankingNos = const {},
      this.simpleMeanings = const {},
      this.starCounts = const {}});
}

class SearchJpnEspWordOutputData {
  final List<JpnEspWord> wordList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  const SearchJpnEspWordOutputData(this.wordList,
      {this.rankingNos = const {},
      this.simpleMeanings = const {},
      this.starCounts = const {}});
}

class SearchConjugacionOutputData {
  final List<SearchResultConjugacions> wordList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  const SearchConjugacionOutputData(this.wordList,
      {this.rankingNos = const {},
      this.simpleMeanings = const {},
      this.starCounts = const {}});
}

class SearchQuizOutputData {
  final List<ConjugacionSearchResultItem> quizList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  const SearchQuizOutputData(this.quizList,
      {this.rankingNos = const {},
      this.simpleMeanings = const {},
      this.starCounts = const {}});
}
