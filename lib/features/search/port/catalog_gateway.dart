import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';

/// Search-owned, provider-neutral raw values. The app maps Catalog values here.
abstract interface class SearchCatalogGateway {
  Future<List<SearchPrimaryRawHit>> searchPrimary(SearchRawQuery query);
  Future<List<SearchConjugationRawHit>> searchConjugations(SearchRawQuery query);
  Future<Map<CatalogWordRef, String>> getMeanings(Iterable<CatalogWordRef> words);
  Future<Map<CatalogWordRef, String>> getHeadwords(Iterable<CatalogWordRef> words);
  Future<Map<CatalogWordRef, int>> getRankingMetadata(Iterable<CatalogWordRef> words);
}

final class SearchRawQuery {
  const SearchRawQuery({required this.text, required this.page, required this.size, required this.espJpn});
  final String text;
  final int page;
  final int size;
  final bool espJpn;
}

final class SearchPrimaryRawHit {
  const SearchPrimaryRawHit({required this.word, required this.headword, required this.hasConjugation});
  final CatalogWordRef word;
  final String headword;
  final bool hasConjugation;
}

final class SearchConjugationRawHit {
  SearchConjugationRawHit({required this.word, required this.headword, required Map<String, String> matches}) : matches = Map.unmodifiable(matches);
  final CatalogWordRef word;
  final String headword;
  final Map<String, String> matches;
}
