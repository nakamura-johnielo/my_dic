import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Provider-neutral request for Catalog's primary dictionary hit capability.
final class CatalogRawSearchQuery {
  const CatalogRawSearchQuery({
    required this.catalogId,
    required this.text,
    required this.page,
    required this.size,
  })  : assert(page >= 0),
        assert(size > 0);

  /// Catalog scope is explicit so paging remains within one stable result set.
  final CatalogId catalogId;
  final String text;
  final int page;
  final int size;
}

/// Raw dictionary hit; Search owns all display and paging policy above this.
final class CatalogPrimaryRawHit {
  const CatalogPrimaryRawHit({
    required this.word,
    required this.headword,
    required this.hasConjugation,
  });

  final CatalogWordRef word;
  final String headword;
  final bool hasConjugation;
}

/// Raw conjugation hit. Match names are Catalog wire keys, not Search DTOs.
final class CatalogConjugationRawHit {
  CatalogConjugationRawHit({
    required this.word,
    required this.headword,
    required Map<String, String> matches,
  }) : matches = Map.unmodifiable(matches);

  final CatalogWordRef word;
  final String headword;
  final Map<String, String> matches;
}

/// Catalog-owned raw reads required by Search and other consumers.
abstract interface class CatalogRawSearchReader {
  Future<List<CatalogPrimaryRawHit>> searchPrimary(CatalogRawSearchQuery query);

  Future<List<CatalogConjugationRawHit>> searchConjugations(
    CatalogRawSearchQuery query,
  );

  Future<Map<CatalogWordRef, String>> getMeanings(
      Iterable<CatalogWordRef> words);

  Future<Map<CatalogWordRef, String>> getHeadwords(
      Iterable<CatalogWordRef> words);

  Future<Map<CatalogWordRef, int>> getRankingMetadata(
    Iterable<CatalogWordRef> words,
  );
}
