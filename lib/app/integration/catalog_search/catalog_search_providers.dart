import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/catalog/port/raw_search_reader.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/composition.dart';
import 'package:my_dic/features/search/port/reader.dart';

/// App-owned, value-only adapter from Catalog raw reads to Search's gateway.
final class CatalogSearchGateway implements SearchCatalogGateway {
  CatalogSearchGateway(this._catalog);
  final CatalogRawSearchReaderPort _catalog;

  @override
  Future<List<SearchPrimaryRawHit>> searchPrimary(SearchRawQuery query) async =>
      (await _catalog.searchPrimary(CatalogRawSearchQuery(text: query.text, page: query.page, size: query.size, catalogId: query.espJpn ? CatalogId.espJpnMain : CatalogId.jpnEspMain)))
          .map((hit) => SearchPrimaryRawHit(word: hit.word, headword: hit.headword, hasConjugation: hit.hasConjugation)).toList(growable: false);

  @override
  Future<List<SearchConjugationRawHit>> searchConjugations(SearchRawQuery query) async =>
      (await _catalog.searchConjugations(CatalogRawSearchQuery(text: query.text, page: query.page, size: query.size, catalogId: query.espJpn ? CatalogId.espJpnMain : CatalogId.jpnEspMain)))
          .map((hit) => SearchConjugationRawHit(word: hit.word, headword: hit.headword, matches: hit.matches)).toList(growable: false);

  @override
  Future<Map<CatalogWordRef, String>> getHeadwords(Iterable<CatalogWordRef> words) => _catalog.getHeadwords(words);
  @override
  Future<Map<CatalogWordRef, String>> getMeanings(Iterable<CatalogWordRef> words) => _catalog.getMeanings(words);
  @override
  Future<Map<CatalogWordRef, int>> getRankingMetadata(Iterable<CatalogWordRef> words) => _catalog.getRankingMetadata(words);
}

final searchReaderPortProvider = Provider<SearchReaderPort>((ref) =>
    createSearchComposition(CatalogSearchGateway(ref.read(catalogCompositionProvider).rawSearchReaderPort)));
