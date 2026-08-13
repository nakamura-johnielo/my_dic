import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_dic/app/bootstrap/catalog_composition.dart';
import 'package:my_dic/features/catalog/port/catalog.dart';
import 'package:my_dic/features/quiz/port/composition.dart';
import 'package:my_dic/features/quiz/port/presentation_dependencies.dart';
import 'package:my_dic/features/quiz/port/quiz.dart';
import 'package:my_dic/features/search/port/model/search_query.dart';
import 'package:my_dic/features/search/port/model/search_result_page.dart';
import 'package:my_dic/features/search/port/reader.dart';
import 'package:my_dic/integration/catalog_quiz/catalog_quiz_providers.dart';
import 'package:my_dic/integration/catalog_search/catalog_search_providers.dart';

void main() {
  test('resolves Catalog readers through the public Catalog composition', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final first = container.read(catalogReadPortsProvider);
    final second = container.read(catalogReadPortsProvider);

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
    expect(container.read(catalogQueryPortProvider), same(first.entryDetail));
    expect(
      container.read(conjugationQueryPortProvider),
      same(first.conjugation),
    );
  });

  test('wires only Quiz Catalog gateways from public Catalog read ports', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(quizCandidateCatalogGatewayProvider),
      isA<QuizCandidateCatalogGateway>(),
    );
    expect(
      container.read(quizGameCatalogGatewayProvider),
      isA<QuizGameCatalogGateway>(),
    );
    final wiring = File(
      'lib/integration/catalog_quiz/catalog_quiz_providers.dart',
    ).readAsStringSync();
    expect(wiring, contains('catalogReadPortsProvider'));
  });

  test('resolves Search reader through the Catalog integration adapter', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(searchQueryPortProvider),
      isA<SearchQueryPort>(),
    );
  });

  test('allows Search reader to be replaced at the composition boundary', () {
    final repository = _SearchQueryPort();
    final container = ProviderContainer(
      overrides: [searchQueryPortProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(searchQueryPortProvider), same(repository));
  });

  test('injects focused Quiz readers from the QuizPorts bundle', () {
    final candidateReader = _QuizCandidateReader();
    final gameReader = _QuizGameReader();
    final ports = QuizPorts(
      candidateReader: candidateReader,
      gameReader: gameReader,
    );
    final container = ProviderContainer(
      overrides: [quizPortsDependencyProvider.overrideWithValue(ports)],
    );
    addTearDown(container.dispose);

    expect(
      container.read(quizCandidateReaderDependencyProvider),
      same(candidateReader),
    );
    expect(container.read(quizGameReaderDependencyProvider), same(gameReader));
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

final class _SearchQueryPort implements SearchQueryPort {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      throw UnimplementedError();
}
