import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/features/catalog/port/catalog.dart' show CatalogWordRef;
import 'package:my_dic/features/search/port/composition.dart';
import 'package:my_dic/features/search/port/search.dart';

void main() {
  test('assembles the completed reader from typed immutable dependencies', () {
    final gateway = _Gateway();
    final dependencies = SearchDependencies(catalogGateway: gateway);

    final ports = createSearchComposition(dependencies: dependencies);

    expect(dependencies.catalogGateway, same(gateway));
    expect(ports.reader, isA<SearchQueryPort>());
  });

  test('composition is a pure exact seam to the same-feature factory', () {
    final source = File(
      'lib/features/search/port/composition.dart',
    ).readAsStringSync();

    expect(
      source,
      contains(
        'features/search/internal/composition/search_composition_factory.dart',
      ),
    );
    expect(source, isNot(contains('flutter_riverpod')));
    expect(source, isNot(contains('integration/catalog_search')));
  });
}

final class _Gateway implements SearchCatalogGateway {
  @override
  Future<Result<Map<CatalogWordRef, SearchFrequencyMetadata>>> readFrequencies(
    Iterable<CatalogWordRef> words,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<Map<CatalogWordRef, SearchMeaningMetadata>>> readMeanings(
    Iterable<CatalogWordRef> words,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<Map<CatalogWordRef, SearchRankingMetadata>>> readRankings(
    Iterable<CatalogWordRef> words,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<SearchCatalogPage<SearchConjugationHit>>> searchConjugations(
    SearchCatalogQuery query,
  ) async =>
      throw UnimplementedError();

  @override
  Future<Result<SearchCatalogPage<SearchPrimaryHit>>> searchPrimary(
    SearchCatalogQuery query,
  ) async =>
      throw UnimplementedError();
}
