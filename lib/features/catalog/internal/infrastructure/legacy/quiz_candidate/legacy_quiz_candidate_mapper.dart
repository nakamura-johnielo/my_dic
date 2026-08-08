import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/quiz/application/candidate_search/quiz_candidate.dart';

/// Pure projections owned by the Catalog-side Quiz adapter.
QuizCandidate mapLegacyQuizCandidate({
  required int wordId,
  required String headword,
  required String? meaningText,
  required int? rankingNo,
  required int? starCount,
}) =>
    QuizCandidate(
      word: CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: wordId),
      headword: headword,
      meaningText: meaningText,
      rankingNo: rankingNo,
      starCount: starCount,
    );

String extractLegacyQuizMeaningText(String html) {
  final meanings = RegExp(
    r'<p data-orgtag="meaning"[^>]*>(.*?)</p>',
    dotAll: true,
  ).allMatches(html).map((match) => _stripTags(match.group(1)!)).where(
        (meaning) => meaning.isNotEmpty,
      );
  return meanings.join('  ');
}

int legacyQuizStarCountFromHeadword(String headword) =>
    RegExp(r'<sup>\((\*+)\)</sup>').firstMatch(headword)?.group(1)?.length ?? 0;

String _stripTags(String value) =>
    value.replaceAll(RegExp(r'<[^>]+>'), '').trim();
