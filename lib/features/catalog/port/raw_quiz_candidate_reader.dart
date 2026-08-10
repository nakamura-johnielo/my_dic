import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Provider-neutral request for raw Quiz candidate hits.
final class CatalogRawQuizCandidateQuery {
  const CatalogRawQuizCandidateQuery({
    required this.text,
    required this.page,
    required this.size,
  })  : assert(page >= 0),
        assert(size > 0);

  final String text;
  final int page;
  final int size;
}

/// A Catalog-owned raw candidate. Quiz supplies all display/paging policy.
final class CatalogRawQuizCandidateHit {
  const CatalogRawQuizCandidateHit({required this.word, required this.headword});

  final CatalogWordRef word;
  final String headword;
}

/// Raw Catalog capability consumed by Quiz candidate policy.
abstract interface class CatalogRawQuizCandidateReader {
  Future<List<CatalogRawQuizCandidateHit>> searchQuizCandidates(
    CatalogRawQuizCandidateQuery query,
  );

  Future<Map<CatalogWordRef, String>> getQuizCandidateMeanings(
    Iterable<CatalogWordRef> words,
  );

  Future<Map<CatalogWordRef, String>> getQuizCandidateHeadwords(
    Iterable<CatalogWordRef> words,
  );

  Future<Map<CatalogWordRef, int>> getQuizCandidateRankingMetadata(
    Iterable<CatalogWordRef> words,
  );
}
