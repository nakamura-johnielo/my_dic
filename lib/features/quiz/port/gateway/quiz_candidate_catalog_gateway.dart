import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;

abstract interface class QuizCandidateCatalogGateway {
  Future<Result<QuizCatalogCandidatePage>> searchConjugationCandidates(
      QuizCatalogCandidateQuery query);
  Future<Result<Map<CatalogWordRef, QuizCatalogMeaning>>> readMeanings(
      Iterable<CatalogWordRef> words);
  Future<Result<Map<CatalogWordRef, QuizCatalogHeadword>>> readHeadwords(
      Iterable<CatalogWordRef> words);
  Future<Result<Map<CatalogWordRef, QuizCatalogRanking>>> readRankings(
      Iterable<CatalogWordRef> words);
}

final class QuizCatalogCandidateQuery {
  const QuizCatalogCandidateQuery(
      {required this.text, required this.page, required this.size});
  final String text;
  final int page;
  final int size;
}

final class QuizCatalogCandidatePage {
  QuizCatalogCandidatePage(
      {required List<QuizCatalogCandidate> items, required this.hasMore})
      : items = List.unmodifiable(items);
  final List<QuizCatalogCandidate> items;
  final bool hasMore;
}

final class QuizCatalogCandidate {
  const QuizCatalogCandidate({required this.word, required this.headword});
  final CatalogWordRef word;
  final String headword;
}

final class QuizCatalogMeaning {
  const QuizCatalogMeaning(this.text);
  final String text;
}

final class QuizCatalogHeadword {
  const QuizCatalogHeadword({required this.text, required this.frequency});
  final String text;
  final int frequency;
}

final class QuizCatalogRanking {
  const QuizCatalogRanking(this.rank);
  final int rank;
}
