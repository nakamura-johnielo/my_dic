import 'package:my_dic/core/shared/utils/result.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/error/quiz_catalog_gateway_error.dart';

/// Consumer-owned boundary used by Quiz to discover and enrich candidates.
abstract interface class QuizCatalogGateway {
  Future<Result<QuizCatalogPage<QuizConjugationCandidate>>>
      searchConjugationCandidates(QuizCatalogQuery query);

  Future<Result<Map<CatalogWordRef, QuizMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  );

  Future<Result<Map<CatalogWordRef, QuizHeadwordMetadata>>>
      readHeadwordMetadata(Iterable<CatalogWordRef> words);

  Future<Result<Map<CatalogWordRef, QuizRankingMetadata>>> readRankingMetadata(
      Iterable<CatalogWordRef> words);
}

final class QuizCatalogQuery {
  const QuizCatalogQuery({
    required this.text,
    required this.page,
    required this.size,
  });

  final String text;
  final int page;
  final int size;
}

final class QuizCatalogPage<T> {
  QuizCatalogPage({required List<T> items, required this.hasMore})
      : items = List.unmodifiable(items);

  final List<T> items;
  final bool hasMore;
}

final class QuizConjugationCandidate {
  const QuizConjugationCandidate({
    required this.word,
    required this.headword,
  });

  final CatalogWordRef word;
  final String headword;
}

final class QuizMeaningMetadata {
  const QuizMeaningMetadata(this.text);
  final String text;
}

/// A clean headword and its typed Catalog frequency level.
final class QuizHeadwordMetadata {
  const QuizHeadwordMetadata({
    required this.headword,
    required this.frequency,
  });

  final String headword;
  final int frequency;
}

final class QuizRankingMetadata {
  const QuizRankingMetadata(this.rankingNo);
  final int rankingNo;
}

typedef QuizGatewayError = QuizCatalogGatewayError;
