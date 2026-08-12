import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';
import 'package:my_dic/features/catalog/port/model/catalog_search_models.dart';

class SearchResultConjugacions {
  SearchResultConjugacions({
    required this.wordId,
    required this.word,
    required this.matches,
  });

  int wordId;
  String word;
  Map<CatalogConjugationMatch, String> matches;
}

class MatchPart {
  CatalogMoodTense moodTense;
  CatalogSubject subject;
  String conjugation;

  MatchPart({
    required this.moodTense,
    required this.subject,
    required this.conjugation,
  });
}
