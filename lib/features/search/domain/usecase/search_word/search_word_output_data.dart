import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';
import 'package:my_dic/features/quiz/domain/entity/quiz_searched_item.dart';

class SearchWordOutputData {
  List<EspJpnWord> wordList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;

  SearchWordOutputData(
    this.wordList, {
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });
}

class SearchJpnEspWordOutputData {
  List<JpnEspWord> wordList;
  SearchJpnEspWordOutputData(this.wordList);
}

class SearchConjugacionOutputData {
  List<SearchResultConjugacions> wordList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  SearchConjugacionOutputData(
    this.wordList, {
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });
}

class SearchQuizOutputData {
  List<QuizSearchedItem> quizList;
  final Map<int, int> rankingNos;
  final Map<int, String> simpleMeanings;
  final Map<int, int> starCounts;
  SearchQuizOutputData(
    this.quizList, {
    this.rankingNos = const {},
    this.simpleMeanings = const {},
    this.starCounts = const {},
  });
}
