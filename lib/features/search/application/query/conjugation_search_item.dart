import 'package:my_dic/core/shared/enums/conjugacion/enum_mood_tense_subject.dart';

/// A conjugation suggestion returned alongside a dictionary search page.
class ConjugationSearchItem {
  ConjugationSearchItem({
    required this.wordId,
    required this.headword,
    required Map<MoodTenseSubject, String> matches,
    required this.meaningText,
    required this.rankingNo,
    required this.starCount,
  }) : matches = Map.unmodifiable(matches);

  final int wordId;
  final String headword;
  final Map<MoodTenseSubject, String> matches;

  /// Full plain-text meaning for the suggested verb.
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;
}
