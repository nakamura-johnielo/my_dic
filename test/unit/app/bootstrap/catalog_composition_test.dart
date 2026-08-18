import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/feature_composition/catalog_composition.dart';
import 'package:my_dic/app/bootstrap/feature_composition/quiz_composition.dart';
import 'package:my_dic/core/composition/data_di.dart';
import 'package:my_dic/core/infrastructure/database/drift/database_provider.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/composition.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/features/search/port/search.dart';
import 'package:my_dic/integration/catalog_search/catalog_search_providers.dart';

void main() {
  test('resolves Catalog readers through the public Catalog composition', () {
    final database = DatabaseProvider.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(database.close);
    addTearDown(container.dispose);

    final first = container.read(catalogQueryPortsProvider);
    final second = container.read(catalogQueryPortsProvider);

    expect(second, same(first));
    expect(first.entryDetail, isA<CatalogEntryDetailQueryPort>());
    expect(first.conjugation, isA<CatalogConjugationQueryPort>());
    expect(first.wordSearch, isA<CatalogWordSearchQueryPort>());
    expect(
      first.conjugationSearch,
      isA<CatalogConjugationSearchQueryPort>(),
    );
    expect(first.entrySummary, isA<CatalogEntrySummaryQueryPort>());
    expect(first.ranking, isA<CatalogRankingQueryPort>());
    expect(first.rankedEntries, isA<CatalogRankedEntryFeedQueryPort>());
    expect(
      first.semanticEntryDetail,
      isA<CatalogSemanticEntryDetailQueryPort>(),
    );
  });

  test('wires both Quiz gateways to the same Catalog completed provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final catalog = container.read(catalogQueryPortsProvider);
    expect(
      container.read(quizCandidateCatalogGatewayProvider),
      isA<QuizCandidateCatalogGateway>(),
    );
    expect(
      container.read(quizGameCatalogGatewayProvider),
      isA<QuizGameCatalogGateway>(),
    );
    expect(container.read(catalogQueryPortsProvider), same(catalog));
    final wiring = File(
      'lib/app/bootstrap/feature_composition/quiz_composition.dart',
    ).readAsStringSync();
    expect(
      RegExp(r'ref\.watch\(catalogQueryPortsProvider\)').allMatches(wiring),
      hasLength(2),
    );
  });

  test('resolves Search reader through the Catalog integration adapter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(searchReaderPortProvider),
      isA<SearchQueryPort>(),
    );
  });

  test('allows Search reader to be replaced at the composition boundary', () {
    final repository = _SearchReaderPort();
    final container = ProviderContainer(
      overrides: [searchReaderPortProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(searchReaderPortProvider), same(repository));
  });

  test('keeps focused Quiz readers together in the app-owned QuizPorts bundle',
      () {
    final candidateReader = _QuizCandidateReader();
    final gameReader = _QuizGameReader();
    final ports = QuizPorts(
      candidateReader: candidateReader,
      gameReader: gameReader,
    );
    expect(ports.candidateReader, same(candidateReader));
    expect(ports.gameReader, same(gameReader));
  });
}

final class _QuizCandidateReader implements QuizCandidateQueryPort {
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async =>
      throw UnimplementedError();
}

final class _QuizGameReader implements QuizGameQueryPort {
  @override
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query) async =>
      throw UnimplementedError();
}

final class _SearchReaderPort implements SearchQueryPort {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      throw UnimplementedError();
}
