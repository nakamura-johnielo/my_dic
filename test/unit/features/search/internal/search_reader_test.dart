import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog_id.dart';
import 'package:my_dic/features/catalog/port/catalog_word_ref.dart';
import 'package:my_dic/features/search/internal/search_reader.dart';
import 'package:my_dic/features/search/port/catalog_gateway.dart';
import 'package:my_dic/features/search/port/model/search_direction.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';

void main() {
  const word = CatalogWordRef(catalogId: CatalogId.espJpnMain, wordId: 7);

  test('owns paging, page-zero suggestions, snippets and stars', () async {
    final gateway = _Gateway(primary: const [SearchPrimaryRawHit(word: word, headword: 'hablar<sup>(**)</sup>', hasConjugation: true)], suggestions: [SearchConjugationRawHit(word: word, headword: 'hablar', matches: const {'indicative_present_yo': 'hablo'})]);
    final result = await InternalSearchReader(gateway).search(const SearchQuery(text: 'hab', direction: SearchDirection.espJpn, page: 0, size: 1, includeConjugationSuggestions: true));
    expect(result.isSuccess, isTrue, reason: result.errorOrNull?.toString());
    final page = result.dataOrNull!;
    expect(page.hasNext, isTrue);
    expect(page.items.single.meaningText, 'speak');
    expect(page.items.single.starCount, 2);
    expect(page.conjugationSuggestions, hasLength(1));
    expect(gateway.suggestionCalls, 1);
  });

  test('does not request suggestions outside the first Esp-Jpn page', () async {
    final gateway = _Gateway();
    await InternalSearchReader(gateway).search(const SearchQuery(text: 'hab', direction: SearchDirection.espJpn, page: 1, size: 20, includeConjugationSuggestions: true));
    expect(gateway.suggestionCalls, 0);
  });

  test('keeps primary data and reports a partial enrichment failure', () async {
    final gateway = _Gateway(primary: const [SearchPrimaryRawHit(word: word, headword: 'hablar', hasConjugation: true)], failMeanings: true);
    final result = await InternalSearchReader(gateway).search(const SearchQuery(text: 'hab', direction: SearchDirection.espJpn, page: 0, size: 20, includeConjugationSuggestions: false));
    expect(result.isSuccess, isTrue, reason: result.errorOrNull?.toString());
    final page = result.dataOrNull!;
    expect(page.items, hasLength(1));
    expect(page.issues.single.source, 'meaning');
  });
}

final class _Gateway implements SearchCatalogGateway {
  _Gateway({this.primary = const [], this.suggestions = const [], this.failMeanings = false});
  final List<SearchPrimaryRawHit> primary;
  final List<SearchConjugationRawHit> suggestions;
  final bool failMeanings;
  int suggestionCalls = 0;
  @override Future<List<SearchPrimaryRawHit>> searchPrimary(SearchRawQuery query) async => primary;
  @override Future<List<SearchConjugationRawHit>> searchConjugations(SearchRawQuery query) async { suggestionCalls++; return suggestions; }
  @override Future<Map<CatalogWordRef, String>> getMeanings(Iterable<CatalogWordRef> words) async { if (failMeanings) throw StateError('meaning'); return {for (final word in words) word: 'speak'}; }
  @override Future<Map<CatalogWordRef, String>> getHeadwords(Iterable<CatalogWordRef> words) async => {for (final word in words) word: 'hablar<sup>(**)</sup>'};
  @override Future<Map<CatalogWordRef, int>> getRankingMetadata(Iterable<CatalogWordRef> words) async => {for (final word in words) word: 1};
}
