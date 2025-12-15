import 'package:my_dic/core/domain/entity/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/core/domain/entity/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/core/domain/entity/word/word.dart';

class SearchWordOutputData {
  List<EspJpnWord> wordList;
  SearchWordOutputData(this.wordList);
}

class SearchJpnEspWordOutputData {
  List<JpnEspWord> wordList;
  SearchJpnEspWordOutputData(this.wordList);
}

class SearchConjugacionOutputData {
  List<SearchResultConjugacions> wordList;
  SearchConjugacionOutputData(this.wordList);
}
