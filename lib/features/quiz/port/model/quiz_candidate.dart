import 'package:my_dic/features/catalog/port/catalog.dart';

/// Search-ready Quiz metadata for one Catalog word.
final class QuizCandidate {
  const QuizCandidate({
    required this.word,
    required this.headword,
    required this.meaningText,
    required this.rankingNo,
    required this.starCount,
  });

  /// Typed identity of the Catalog word used to start the Quiz.
  final CatalogWordRef word;
  final String headword;
  final String? meaningText;
  final int? rankingNo;
  final int? starCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizCandidate &&
          word == other.word &&
          headword == other.headword &&
          meaningText == other.meaningText &&
          rankingNo == other.rankingNo &&
          starCount == other.starCount;

  @override
  int get hashCode =>
      Object.hash(word, headword, meaningText, rankingNo, starCount);
}
