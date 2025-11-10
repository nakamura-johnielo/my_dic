import 'package:my_dic/Constants/Enums/enum_mood_tense_subject.dart';
import 'package:my_dic/Constants/Enums/mood_tense.dart';
import 'package:my_dic/Constants/Enums/subject.dart';
import 'package:my_dic/_Business_Rule/_Domain/Entities/verb/conjugacion/tense_conjugacion.dart';

class SearchResultConjugacions {
  SearchResultConjugacions(
      {
      //required int conjugacionId,
      required this.wordId,
      required this.word,
      //required this.conjugacions,
      required this.matches
      // デフォルト値は「@Default([デフォルト値]])」の形式で指定可能
      });
  int wordId;
  String word;
  Map<MoodTenseSubject, String> matches;
  //List<MatchPart> matches;
}

class MatchPart {
  MoodTense moodTense;
  Subject subject;
  String conjugation;
  MatchPart({
    //required int conjugacionId,
    required this.moodTense,
    required this.subject,
    required this.conjugation,
    // デフォルト値は「@Default([デフォルト値]])」の形式で指定可能
  });
}
