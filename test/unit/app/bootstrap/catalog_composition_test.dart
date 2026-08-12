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
    expect(first.entryDetail, isA<CatalogEntryDetailReaderPort>());
    expect(first.conjugation, isA<CatalogConjugationReaderPort>());
    expect(first.wordSearch, isA<CatalogWordSearchReaderPort>());
    expect(
      first.conjugationSearch,
      isA<CatalogConjugationSearchReaderPort>(),
    );
    expect(first.entrySummary, isA<CatalogEntrySummaryReaderPort>());
    expect(first.ranking, isA<CatalogRankingReaderPort>());
    expect(container.read(catalogReaderPortProvider), same(first.entryDetail));
    expect(
      container.read(conjugationReaderPortProvider),
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
      container.read(searchReaderPortProvider),
      isA<SearchReaderPort>(),
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

final class _QuizCandidateReader implements QuizCandidateReaderPort {
  @override
  Future<Result<QuizCandidatePage>> search(QuizCandidateQuery query) async =>
      throw UnimplementedError();
}

final class _QuizGameReader implements QuizGameReaderPort {
  @override
  Future<Result<QuizGameLoadOutcome>> load(QuizGameQuery query) async =>
      throw UnimplementedError();
}

final class _SearchReaderPort implements SearchReaderPort {
  @override
  Future<Result<SearchResultPage>> search(SearchQuery query) async =>
      throw UnimplementedError();
}
