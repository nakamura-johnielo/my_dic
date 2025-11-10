import 'package:my_dic/_Business_Rule/_Domain/Entities/jpn_esp/jpn_esp_word.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/result_conjugacions.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/word/word.dart';

class SearchWordOutputData {
  List<Word> wordList;
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
