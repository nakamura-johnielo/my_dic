import 'package:my_dic/features/catalog/port/model/catalog_conjugation.dart';

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

class CatalogConjugationMatch {
  const CatalogConjugationMatch({required this.moodTense, this.subject});

  final CatalogMoodTense moodTense;
  final CatalogSubject? subject;
}
